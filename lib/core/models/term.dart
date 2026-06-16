/// Akademik dönem: yıl + sezon (Güz / Bahar) + isteğe bağlı başlangıç/bitiş.
enum TermSeason { guz, bahar }

class Term {
  final int year;
  final TermSeason season;
  final DateTime? startDate; // dönem başlangıcı (kullanıcı belirler)
  final DateTime? endDate; // dönem bitişi

  const Term({required this.year, required this.season, this.startDate, this.endDate});

  /// Kullanıcıya gösterilen etiket: "2024 Güz".
  String get label => '$year ${season == TermSeason.guz ? 'Güz' : 'Bahar'}';

  /// Depolama/eşleştirme kimliği: "2024-Güz".
  String get id => '$year-${season == TermSeason.guz ? 'Güz' : 'Bahar'}';

  /// Tarih belirtilmemişse sezona göre makul varsayılan başlangıç.
  DateTime get defaultStart => season == TermSeason.guz
      ? DateTime(year, 9, 15)
      : DateTime(year, 2, 10);

  /// Tarih belirtilmemişse sezona göre makul varsayılan bitiş.
  DateTime get defaultEnd => season == TermSeason.guz
      ? DateTime(year + 1, 1, 15)
      : DateTime(year, 6, 20);

  DateTime get effectiveStart => startDate ?? defaultStart;
  DateTime get effectiveEnd => endDate ?? defaultEnd;

  /// Verilen gün dönem aralığında mı (gün bazında, dahil).
  bool contains(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final s = DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day);
    final e = DateTime(effectiveEnd.year, effectiveEnd.month, effectiveEnd.day);
    return !day.isBefore(s) && !day.isAfter(e);
  }

  /// Bugünün tarihinden varsayılan dönemi türetir.
  factory Term.current([DateTime? now]) {
    final d = now ?? DateTime.now();
    if (d.month >= 9) {
      return Term(year: d.year, season: TermSeason.guz);
    } else if (d.month <= 1) {
      return Term(year: d.year - 1, season: TermSeason.guz);
    } else {
      return Term(year: d.year, season: TermSeason.bahar);
    }
  }

  /// "2024-Güz" biçimindeki kimliği geri çözer (tarihsiz).
  factory Term.fromId(String id) {
    final parts = id.split('-');
    final year = int.tryParse(parts.first) ?? DateTime.now().year;
    final season =
        (parts.length > 1 && parts[1] == 'Bahar') ? TermSeason.bahar : TermSeason.guz;
    return Term(year: year, season: season);
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'season': season == TermSeason.guz ? 'Güz' : 'Bahar',
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        year: json['year'] ?? DateTime.now().year,
        season: json['season'] == 'Bahar' ? TermSeason.bahar : TermSeason.guz,
        startDate: (json['startDate'] != null) ? DateTime.tryParse(json['startDate']) : null,
        endDate: (json['endDate'] != null) ? DateTime.tryParse(json['endDate']) : null,
      );

  Term copyWith({int? year, TermSeason? season, DateTime? startDate, DateTime? endDate}) =>
      Term(
        year: year ?? this.year,
        season: season ?? this.season,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  @override
  bool operator ==(Object other) =>
      other is Term && other.year == year && other.season == season;

  @override
  int get hashCode => Object.hash(year, season);
}
