import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Note> _notes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await DatabaseHelper.instance.getAllNotes();
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  Future<void> _addNote() async {
    // Перевірка валідації форми
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = Note(
        text: _controller.text.trim(),
        dateCreated: DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now()),
      );

      await DatabaseHelper.instance.insertNote(note);
      _controller.clear();

      // Приховати клавіатуру
      FocusScope.of(context).unfocus();

      await _loadNotes();

      // Показати повідомлення про успіх
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нотатку додано!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error adding note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      await DatabaseHelper.instance.deleteNote(id);
      await _loadNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нотатку видалено!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Введіть текст',
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Поле є обов\'язковим';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _addNote(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? const Center(
              child: Text(
                'Немає нотаток',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    title: Text(note.text),
                    subtitle: Text(
                      note.dateCreated,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
