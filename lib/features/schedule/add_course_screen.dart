import 'package:flutter/material.dart';
import '../../core/models/course_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class AddCourseScreen extends StatefulWidget {
  /// Düzenleme modu için var olan ders verilir; yeni ekleme için null.
  final Course? existing;

  /// Aynı isim ve günlük ders limiti kontrolleri için tüm dersler.
  final List<Course> allCourses;

  const AddCourseScreen({super.key, this.existing, this.allCourses = const []});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  int _rights = 4;
  final List<String> _weekDays = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar",
  ];
  final List<String> _selectedDays = [];
  TimeOfDay? _time;
  String _activeTermId = '';

  late final AnimationController _introController;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _rights = e.rightsLeft;
      _selectedDays.addAll(e.days);
      _time = _parseTime(e.time);
      _activeTermId = e.term;
    } else {
      StorageService.getActiveTerm().then((t) {
        if (mounted) setState(() => _activeTermId = t.id);
      });
    }
  }

  TimeOfDay? _parseTime(String hhmm) {
    if (hhmm.isEmpty || !hhmm.contains(':')) return null;
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0');
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Türkçe karakterlere duyarlı küçük harfe çevirme (İ→i, I→ı).
  String _trLower(String s) =>
      s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase().trim();

  void _warn(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kVibrantRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveCourse() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _warn("Lütfen bir ders adı girin.");
      return;
    }
    if (_selectedDays.isEmpty) {
      _warn("Lütfen en az bir gün seçin.");
      return;
    }

    final termId = _isEditMode ? widget.existing!.term : _activeTermId;

    // Aynı dönemdeki diğer dersler (düzenlenen ders hariç).
    final others = widget.allCourses
        .where((c) => c.id != widget.existing?.id && c.term == termId)
        .toList();

    // Aynı isimli ders engeli (büyük/küçük harf duyarsız, Türkçe uyumlu).
    final lowerName = _trLower(name);
    if (others.any((c) => _trLower(c.name) == lowerName)) {
      _warn("Bu isimde bir ders zaten ekli. Aynı ders iki kez eklenemez.");
      return;
    }

    // Günlük ders limiti: bir güne en fazla 6 ders.
    for (final day in _selectedDays) {
      final countOnDay = others.where((c) => c.days.contains(day)).length;
      if (countOnDay >= 6) {
        _warn("Bir güne en fazla 6 ders eklenebilir. ($day dolu)");
        return;
      }
    }

    final Course result;
    if (_isEditMode) {
      result = widget.existing!.copyWith(
        name: name,
        time: _formatTime(_time),
        rightsLeft: _rights,
        days: List<String>.from(_selectedDays),
      );
    } else {
      result = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        time: _formatTime(_time),
        rightsLeft: _rights,
        days: List<String>.from(_selectedDays),
        term: _activeTermId,
      );
    }

    Navigator.pop(context, result);
  }

  @override
  void dispose() {
    _introController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// İçeriği aşağıdan yukarı kayarak ve solarak getiren giriş animasyonu.
  Widget _animatedSection(int index, Widget child) {
    final start = (0.08 * index).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = cs.onSurface;
    final Color hintColor = textColor.withValues(alpha: 0.25);
    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _animatedSection(
                0,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? "Dersi Düzenle" : "Yeni Ders Ekle",
                      style: screenTitleStyle(textColor),
                    ),
                    const SizedBox(height: 8),
                    titleUnderline(),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _animatedSection(
                1,
                _sectionCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  icon: Icons.menu_book_outlined,
                  label: "DERSİN ADI",
                  child: TextField(
                    controller: _nameController,
                    maxLength: 40,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: kVibrantRed,
                    decoration: InputDecoration(
                      hintText: "Örn: Mobil Programlama",
                      hintStyle: TextStyle(color: hintColor, fontSize: 20),
                      counterText: "",
                      isDense: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: textColor.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: kVibrantRed),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _animatedSection(
                2,
                _sectionCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  icon: Icons.access_time,
                  label: "DERS SAATİ · İSTEĞE BAĞLI",
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            _time ?? const TimeOfDay(hour: 9, minute: 0),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: kVibrantRed,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        // Dakikayı en yakın 5'e yuvarla (12:47 → 12:45).
                        int m = (picked.minute / 5).round() * 5;
                        int h = picked.hour;
                        if (m == 60) {
                          m = 0;
                          h = (h + 1) % 24;
                        }
                        setState(() => _time = TimeOfDay(hour: h, minute: m));
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _time == null ? "Saat seç" : _formatTime(_time),
                            style: TextStyle(
                              color: _time == null ? hintColor : textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Row(
                            children: [
                              if (_time != null)
                                InkWell(
                                  onTap: () => setState(() => _time = null),
                                  customBorder: const CircleBorder(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.close,
                                      color: textColor.withValues(alpha: 0.4),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.schedule,
                                color: kVibrantRed.withValues(alpha: 0.7),
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _animatedSection(
                3,
                _sectionCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  icon: Icons.calendar_today_outlined,
                  label: "GÜN SEÇİMİ · BİRDEN FAZLA SEÇİLEBİLİR",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _weekDays.map((day) {
                        final bool isSelected = _selectedDays.contains(day);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? _selectedDays.remove(day)
                                  : _selectedDays.add(day);
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? textColor
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? textColor
                                    : textColor.withValues(alpha: 0.18),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? bgColor : textColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w300,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _animatedSection(
                4,
                _sectionCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  icon: Icons.event_busy_outlined,
                  label: "DEVAMSIZLIK HAKKI",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sınır Belirle",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Row(
                          children: [
                            _buildCounterButton(Icons.remove, textColor, () {
                              setState(() {
                                if (_rights > 1) _rights--;
                              });
                            }),
                            SizedBox(
                              width: 50,
                              child: Text(
                                _rights.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            _buildCounterButton(Icons.add, textColor, () {
                              setState(() {
                                _rights++;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _animatedSection(
                5,
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kVibrantRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kVibrantRed.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditMode
                              ? Icons.check_circle_outline
                              : Icons.add_circle_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditMode
                              ? "DEĞİŞİKLİKLERİ KAYDET"
                              : "DERSİ KAYDET",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.56,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Başlık + içerik barındıran, ince çerçeveli bölüm kartı.
  Widget _sectionCard({
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: cardColor,
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    Color textColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: textColor, size: 22),
      ),
    );
  }
}
