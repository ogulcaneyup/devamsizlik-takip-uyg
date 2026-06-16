class Course {
  final String id;
  final String name;
  String time; // YENİ: gerçek ders saati "HH:mm" (boş olabilir)
  int rightsLeft;
  final List<String> days; // Dersin olduğu günler
  bool notificationMuted; // YENİ: bu ders için bildirim susturuldu mu
  String term; // YENİ: ait olduğu dönem kimliği, örn. "2024-Güz"
  // YENİ: günlük yoklama işaretleri. Anahtar "yyyy-MM-dd", değer
  // "geldim" | "gelmedim" | "iptal". Bir gün için en fazla bir işaret.
  Map<String, String> marks;
  String courseColor; // YENİ: takvimde görünen renk (hex string)

  Course({
    required this.id,
    required this.name,
    required this.time,
    required this.rightsLeft,
    required this.days,
    this.notificationMuted = false,
    this.term = '',
    Map<String, String>? marks,
    String? courseColor,
  }) : marks = marks ?? {},
       courseColor = courseColor ?? _getColorForName(name);

  /// Ders adına göre sabit renk döndür
  static String _getColorForName(String name) {
    final hash = name.hashCode.abs();
    final colorIndex = hash % colorPalette.length;
    return colorPalette[colorIndex];
  }

  /// Tarihi "yyyy-MM-dd" anahtarına çevirir (yerel saat).
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Takvimde ders noktaları için kullanılan renk paleti.
  static const List<String> colorPalette = [
    '#FF2A2A', // Kırmızı
    '#4CAF50', // Yeşil
    '#2196F3', // Mavi
    '#FF9800', // Turuncu
    '#9C27B0', // Mor
    '#FFC107', // Sarı
    '#00BCD4', // Cyan
    '#E91E63', // Pembe
  ];

  /// Bugün dışında diğer günlerin işaretlerini temizler.
  void clearPreviousDayMarks() {
    final today = dayKey(DateTime.now());
    marks.removeWhere((k, v) => k != today);
  }

  /// O güne ait işaret ("geldim"/"gelmedim"/"iptal") ya da null.
  String? markFor(DateTime d) => marks[dayKey(d)];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'rightsLeft': rightsLeft,
      'days': days,
      'notificationMuted': notificationMuted,
      'term': term,
      'marks': marks,
      'courseColor': courseColor,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      // Eski "Belirtilmedi" değerini gerçek saat olmadığı için boşa çeviriyoruz.
      time: () {
        final t = json['time'];
        if (t == null || t == 'Belirtilmedi') return '';
        return t as String;
      }(),
      rightsLeft: json['rightsLeft'],
      // Eski verilerde gün yoksa çökmemesi için güvenlik önlemi:
      days: List<String>.from(json['days'] ?? []),
      notificationMuted: json['notificationMuted'] ?? false,
      term: json['term'] ?? '',
      marks:
          (json['marks'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
      courseColor: json['courseColor'] as String?,
    );
  }

  Course copyWith({
    String? name,
    String? time,
    int? rightsLeft,
    List<String>? days,
    bool? notificationMuted,
    String? term,
    Map<String, String>? marks,
    String? courseColor,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      time: time ?? this.time,
      rightsLeft: rightsLeft ?? this.rightsLeft,
      days: days ?? this.days,
      notificationMuted: notificationMuted ?? this.notificationMuted,
      term: term ?? this.term,
      marks: marks ?? this.marks,
      courseColor: courseColor ?? this.courseColor,
    );
  }

  /// Saatleri sıralamak için dakikaya çevirir. Boşsa en sona atılır.
  int get sortMinutes {
    if (time.isEmpty || !time.contains(':')) return 24 * 60 + 1;
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }
}
