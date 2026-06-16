/// Öğrenci profili.
class Profile {
  String name; // Ad Soyad
  String major; // Bölüm
  int year; // Sınıf (1-8)
  String? photoPath; // Yüklenen profil fotoğrafının dosya yolu (yoksa null)

  Profile({
    this.name = '',
    this.major = '',
    this.year = 1,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'major': major,
        'year': year,
        'photoPath': photoPath,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json['name'] ?? '',
        major: json['major'] ?? '',
        year: json['year'] ?? 1,
        photoPath: json['photoPath'],
      );

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
}
