class Note {
  final int? id;
  final String text;
  final String dateCreated;

  Note({
    this.id,
    required this.text,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'dateCreated': dateCreated,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      dateCreated: map['dateCreated'],
    );
  }
}
