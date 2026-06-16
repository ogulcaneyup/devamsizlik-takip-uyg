import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/profile_model.dart';
import '../../core/models/term.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

/// Profil fotoğrafını (varsa) ya da uygulama tarzında varsayılan avatarı
/// gösteren dairesel widget. Hem profil ekranında hem üst bardaki butonda
/// kullanılır.
class ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double size;
  const ProfileAvatar({super.key, required this.profile, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color border = cs.onSurface.withValues(alpha: 0.15);

    if (profile.hasPhoto && File(profile.photoPath!).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.2),
          image: DecorationImage(image: FileImage(File(profile.photoPath!)), fit: BoxFit.cover),
        ),
      );
    }

    // Varsayılan avatar: kart zemini üzerine silüet (Instagram benzeri ama
    // uygulamanın siyah/beyaz + ince çizgi estetiğinde).
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border: Border.all(color: border, width: 1.2),
      ),
      child: Icon(Icons.person, size: size * 0.6, color: cs.onSurface.withValues(alpha: 0.35)),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  int _year = 1;
  String? _photoPath;
  Term _activeTerm = Term.current();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await StorageService.loadProfile();
    final term = await StorageService.getActiveTerm();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile.name;
      _majorController.text = profile.major;
      _year = profile.year;
      _photoPath = profile.photoPath;
      _activeTerm = term;
      _loaded = true;
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (file != null) {
      setState(() => _photoPath = file.path);
    }
  }

  Future<void> _save() async {
    final profile = Profile(
      name: _nameController.text.trim(),
      major: _majorController.text.trim(),
      year: _year,
      photoPath: _photoPath,
    );
    await StorageService.saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil kaydedildi.")));
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = cs.onSurface;
    final Color hintColor = textColor.withValues(alpha: 0.25);

    final previewProfile = Profile(name: _nameController.text, major: _majorController.text, year: _year, photoPath: _photoPath);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _loaded ? _save : null,
            child: Text("KAYDET", style: TextStyle(color: kVibrantRed, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
          ),
        ],
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Avatar + kamera düğmesi (halka yok).
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          ProfileAvatar(profile: previewProfile, size: 120),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _pickPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: kVibrantRed, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 2)),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Girilen ada göre canlı önizleme.
                    Text(
                      _nameController.text.trim().isEmpty ? "İsimsiz" : _nameController.text.trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: kVibrantRed.withValues(alpha: 0.1), border: Border.all(color: kVibrantRed.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(8)),
                      child: Text(_activeTerm.label, style: const TextStyle(color: kVibrantRed, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 36),

                    _fieldCard(Icons.badge_outlined, "AD SOYAD", _nameController, "Örn: Ada Lovelace", textColor, hintColor, maxLength: 40),
                    const SizedBox(height: 16),
                    _fieldCard(Icons.school_outlined, "BÖLÜM", _majorController, "Örn: Bilgisayar Mühendisliği", textColor, hintColor, maxLength: 30, showCounter: true),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorderColor(context)),
                        boxShadow: cardShadow(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.workspace_premium_outlined, size: 15, color: kVibrantRed.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Text("SINIF", style: sectionLabelStyle(textColor)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$_year. Sınıf", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w300)),
                              Row(
                                children: [
                                  _counter(Icons.remove, textColor, () { setState(() { if (_year > 1) _year--; }); }),
                                  const SizedBox(width: 16),
                                  _counter(Icons.add, textColor, () { setState(() { if (_year < 7) _year++; }); }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _fieldCard(IconData icon, String label, TextEditingController controller, String hint, Color textColor, Color hintColor, {int? maxLength, bool showCounter = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor(context)),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: kVibrantRed.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Text(label, style: sectionLabelStyle(textColor)),
            ],
          ),
          TextField(
            controller: controller,
            maxLength: maxLength,
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w400),
            cursorColor: kVibrantRed,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 18),
              counterText: showCounter ? null : "",
              counterStyle: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 11),
              isDense: true,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _counter(IconData icon, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: textColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: textColor, size: 24),
      ),
    );
  }
}
