/// Bir sınav kaydı (Faz 3'te sınav takviminde kullanılır).
class Exam {
  final String id;
  final String courseId;
  final String courseName;
  DateTime date;
  String time; // "HH:mm"
  String notes; // Önceki sınav sonucu / hatırlatma notları
  String bringList; // Unutma listesi (hesap makinesi, kalem vb.)
  String term; // Ait olduğu dönem kimliği

  Exam({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    this.time = '',
    this.notes = '',
    this.bringList = '',
    this.term = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'courseName': courseName,
        'date': date.toIso8601String(),
        'time': time,
        'notes': notes,
        'bringList': bringList,
        'term': term,
      };

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'],
        courseId: json['courseId'] ?? '',
        courseName: json['courseName'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        time: json['time'] ?? '',
        notes: json['notes'] ?? '',
        bringList: json['bringList'] ?? '',
        term: json['term'] ?? '',
      );
}
