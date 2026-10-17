import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../core/models/course_model.dart';
import '../core/models/exam_model.dart';
import '../core/models/profile_model.dart';
import '../core/models/term.dart';
import '../core/services/storage_service.dart';
import '../core/theme/app_theme.dart';
import 'schedule/add_course_screen.dart';
import 'settings/settings_screen.dart';
import 'profile/profile_screen.dart';
import 'calendar/calendar_screen.dart';
import 'exams/exam_calendar_screen.dart';
import 'exams/exam_add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // "Ders Ekle" butonunun çevresindeki yanıp sönen halka efekti için.
  late final AnimationController _pulseController;
  // Arka plandaki dalganın yavaş, tek yönlü akışı için.
  late final AnimationController _waveController;

  List<Course> _allCourses = [];
  List<Exam> _exams = [];
  Profile _profile = Profile();
  Term _activeTerm = Term.current();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _loadData();
  }

  void _syncControllers() {
    final empty = _termCourses.isEmpty;
    if (empty && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    } else if (!empty && _pulseController.isAnimating) {
      _pulseController.stop();
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Course> get _termCourses =>
      _allCourses.where((c) => c.term == _activeTerm.id).toList();

  Future<void> _loadData() async {
    final term = await StorageService.getActiveTerm();
    final courses = await StorageService.loadCourses();
    final exams = await StorageService.loadExams();
    final profile = await StorageService.loadProfile();

    // Eski işaretleri temizle
    for (final c in courses) {
      c.clearPreviousDayMarks();
    }

    if (!mounted) return;
    setState(() {
      _activeTerm = term;
      _allCourses = courses;
      _exams = exams;
      _profile = profile;
      _isDataLoaded = true;
    });
    _syncControllers();

    await StorageService.saveCourses(courses);
  }

  Future<void> _persist() async {
    await StorageService.saveCourses(_allCourses);
  }

  String _getTodayName() {
    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];
    return days[DateTime.now().weekday - 1];
  }

  //YOKLAMA (günde tek işaret)

  void _markToday(Course course, String status) {
    if (course.markFor(DateTime.now()) != null) return; // gün kilitli
    if (status == 'gelmedim') {
      if (course.rightsLeft <= 0) return;
      course.rightsLeft--;
    }
    setState(() {
      course.marks[Course.dayKey(DateTime.now())] = status;
    });
    _persist();
  }

  void _undoToday(Course course) {
    final key = Course.dayKey(DateTime.now());
    final prev = course.marks[key];
    if (prev == null) return;
    if (prev == 'gelmedim') course.rightsLeft++;
    setState(() {
      course.marks.remove(key);
    });
    _persist();
  }

  //DERS EYLEMLERİ

  void _deleteCourse(Course course) {
    setState(() {
      _allCourses = _allCourses.where((c) => c.id != course.id).toList();
    });
    _syncControllers();
    _persist();
  }

  /// Ders ekleme/düzenleme ekranına köşelerden yumuşayarak açılan,
  /// Sağdan kayarak gelen, alttaki sayfayı sola süren "gelgit" geçişi.
  Route<Course> _courseRoute({Course? existing}) {
    return PageRouteBuilder<Course>(
      transitionDuration: const Duration(milliseconds: 480),
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) =>
          AddCourseScreen(existing: existing, allCourses: _allCourses),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Yeni sayfa sağdan içeri kayar.
        final inSlide = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        // Alttaki (eski) sayfa hafifçe sola çekilir: gelgit hissi.
        final outSlide = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.28, 0.0),
        ).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: outSlide,
          child: SlideTransition(position: inSlide, child: child),
        );
      },
    );
  }

  Future<void> _editCourse(Course course) async {
    final result = await Navigator.push(
      context,
      _courseRoute(existing: course),
    );
    if (result != null) {
      setState(() {
        // Yeni liste referansı: gömülü CalendarScreen değişimi algılasın.
        final updated = List<Course>.from(_allCourses);
        final i = updated.indexWhere((c) => c.id == result.id);
        if (i != -1) updated[i] = result;
        _allCourses = updated;
      });
      _persist();
    }
  }

  Future<void> _addCourse() async {
    // İsim çakışması ve günlük ders limiti kontrolleri AddCourseScreen
    // içinde, kayıt anında yapılır.
    final result = await Navigator.push(context, _courseRoute());
    if (result != null) {
      setState(() {
        _allCourses = [..._allCourses, result];
      });
      _syncControllers();
      _persist();
    }
  }

  // SINAV EYLEMLERİ

  Future<void> _openExamAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamAddScreen(
          courses: _allCourses,
          exams: _exams,
          activeTerm: _activeTerm,
        ),
      ),
    );
    if (result is List<Exam>) {
      setState(() {
        _exams = result;
      });
      await StorageService.saveExams(_exams);
    }
  }

  void _deleteExam(Exam exam) {
    setState(() {
      _exams.removeWhere((e) => e.id == exam.id);
    });
    StorageService.saveExams(_exams);
  }

  // ---------- BAĞLAMA DUYARLI EKLE ----------

  void _onAdd() {
    if (_currentPage == 2) {
      _openExamAdd();
    } else {
      _addCourse();
    }
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    final profile = await StorageService.loadProfile();
    if (mounted) setState(() => _profile = profile);
  }

  // ---------- ARAYÜZ ----------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = cs.onSurface;

    if (!_isDataLoaded) return Scaffold(backgroundColor: bgColor);

    final termCourses = _termCourses;
    final hasLessons = termCourses.isNotEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        // İlk ders eklendiğinde hoş geldin ekranından ana ekrana
        // köşelerden açılan (büyüyen yuvarlak köşe + solma) yavaş geçiş.
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 850),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isMain =
                (child.key as ValueKey?)?.value == 'main';
            if (!isMain) {
              // Çıkan hoş geldin ekranı: yalnızca yumuşakça solsun.
              return FadeTransition(opacity: animation, child: child);
            }
            // Giren ana ekran: köşelerden açılan büyüyen yuvarlak reveal.
            return FadeTransition(
              opacity: animation,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, inner) => ClipRRect(
                  borderRadius: BorderRadius.circular(
                    60 * (1 - animation.value),
                  ),
                  child: Transform.scale(
                    scale: 0.82 + 0.18 * animation.value,
                    child: inner,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: hasLessons
              ? KeyedSubtree(
                  key: const ValueKey('main'),
                  child: Column(
                    children: [
                      _buildTopBar(textColor),
                      _buildTabs(textColor),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const ClampingScrollPhysics(),
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          children: [
                            RepaintBoundary(child: _buildMainPage(textColor)),
                            RepaintBoundary(
                              child: CalendarScreen(
                                courses: _allCourses,
                                activeTerm: _activeTerm,
                              ),
                            ),
                            RepaintBoundary(
                              child: ExamCalendarScreen(
                                exams: _exams,
                                activeTerm: _activeTerm,
                                onDelete: _deleteExam,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('empty'),
                  child: _buildEmptyState(textColor),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        children: [
          InkWell(
            onTap: _openProfile,
            customBorder: const CircleBorder(),
            child: ProfileAvatar(profile: _profile, size: 44),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profile.major.isNotEmpty)
                  Text(
                    _profile.major,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (_profile.year > 0)
                  Text(
                    "${_profile.year}. Sınıf",
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          _topIconButton(
            Icons.settings_outlined,
            textColor,
            onTap: _openSettings,
          ),
          const SizedBox(width: 8),
          // Ekle butonu: dolu kırmızı CTA, beyaz artı — gözü çeken tek nokta.
          InkWell(
            onTap: _onAdd,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kVibrantRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kVibrantRed.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIconButton(
    IconData icon,
    Color textColor, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: elevatedSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor(context)),
        ),
        child: Icon(icon, color: textColor, size: 22),
      ),
    );
  }

  /// Açık (kutusuz) sekme çubuğu: etiketler doğrudan zeminde, aktif olanın
  /// altında ince kırmızı gösterge çizgisi. Sade ama silik değil.
  Widget _buildTabs(Color textColor) {
    const labels = ["ANA", "DERSLER", "SINAVLAR"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: List.generate(
          labels.length,
          (i) => _tabLabel(i, labels[i], textColor),
        ),
      ),
    );
  }

  Widget _tabLabel(int index, String title, Color textColor) {
    final bool active = _currentPage == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active
                      ? kVibrantRed
                      : textColor.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            // Aktif sekmenin altındaki büyüyüp küçülen kırmızı gösterge.
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: 2.5,
              width: active ? 26 : 0,
              decoration: BoxDecoration(
                color: kVibrantRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- ANA SAYFA (ders durumu) ----------

  Widget _buildMainPage(Color textColor) {
    final termCourses = _termCourses;
    if (termCourses.isEmpty) return _buildEmptyState(textColor);

    final todayName = _getTodayName();
    final todays = termCourses.where((c) => c.days.contains(todayName)).toList()
      ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    final all = List<Course>.from(termCourses)
      ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 40),
      physics: const ClampingScrollPhysics(),
      children: [
        _sectionHeader("BUGÜN", todayName.toUpperCase(), textColor),
        if (todays.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.coffee_outlined,
                  size: 20,
                  color: textColor.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
                Text(
                  "Bugün ($todayName) dersin yok.",
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
        else
          ...todays.map((c) => _slidableCard(c, textColor, showActions: true)),
        const SizedBox(height: 20),
        _sectionHeader("TÜM DERSLER", _activeTerm.label, textColor),
        ...all.map((c) => _slidableCard(c, textColor, showActions: false)),
        const SizedBox(height: 10),
        Center(
          child: Text(
            "Kartı sola kaydır: düzenle · sil",
            style: TextStyle(
              color: textColor.withValues(alpha: 0.3),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String trailing, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: sectionLabelStyle(textColor)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slidableCard(
    Course course,
    Color textColor, {
    required bool showActions,
  }) {
    return Slidable(
      key: ValueKey(course.id + (showActions ? '_t' : '_a')),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.5,
        children: [
          _slideAction(
            color: const Color(0xFF00BCD4),
            icon: Icons.edit_outlined,
            label: 'Düzenle',
            onTap: () => _editCourse(course),
          ),
          _slideAction(
            color: kVibrantRed,
            icon: Icons.delete_outline,
            label: 'Sil',
            onTap: () => _deleteCourse(course),
          ),
        ],
      ),
      child: showActions
          ? _buildCourseCard(course, course.rightsLeft <= 2, true, textColor)
          : _buildCompactCourseCard(course, textColor),
    );
  }

  /// "TÜM DERSLER" listesi için kompakt kart: solda dersin durum rengini
  /// taşıyan ince dikey çubuk, yanında ad + gün/saat tek satır. Bugünün
  /// büyük aksiyon kartlarından belirgin biçimde ayrışır.
  Widget _buildCompactCourseCard(Course course, Color textColor) {
    final Color cardBg = Theme.of(context).cardColor;
    final bool critical = course.rightsLeft <= 2;
    final Color accent = critical ? kVibrantRed : textColor.withValues(alpha: 0.25);
    final String meta = course.time.isEmpty
        ? course.days.join(" · ")
        : "${course.time}  ·  ${course.days.join(" · ")}";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor(context)),
        boxShadow: cardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RightsBadge(rights: course.rightsLeft),
        ],
      ),
    );
  }

  /// Kart sola kaydırılınca çıkan tekil aksiyon: yumuşak renk zeminli,
  /// yuvarlak köşeli, ikon üstte yazı altta.
  Widget _slideAction({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        child: Material(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    Course course,
    bool isCritical,
    bool showActions,
    Color textColor,
  ) {
    final Color cardBg = Theme.of(context).cardColor;
    final String? todayMark = course.markFor(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        // Bugünün dersleri: hafif kırmızı tonlu çerçeve (aktif durum).
        border: Border.all(
          color: showActions
              ? kVibrantRed.withValues(alpha: 0.30)
              : cardBorderColor(context),
        ),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Sol saat bloğu: dersin saati yoksa kitap ikonu.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: showActions
                      ? kVibrantRed.withValues(alpha: 0.10)
                      : textColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  // Saat yoksa ikon yerine sade bir tire göster.
                  child: Text(
                    course.time.isEmpty ? "—" : course.time,
                    style: TextStyle(
                      color: showActions
                          ? kVibrantRed
                          : textColor.withValues(alpha: 0.8),
                      fontSize: course.time.isEmpty ? 18 : 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      course.days.join(" · "),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Kalan hak: renge duyarlı pill rozet.
              RightsBadge(rights: course.rightsLeft),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            if (todayMark == null)
              _buildActionRow(course, textColor)
            else
              _buildMarkedRow(todayMark, course, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(Course course, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            "GELDİM",
            kSuccessGreen,
            onTap: () => _markToday(course, 'geldim'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            "GELMEDİM",
            kVibrantRed,
            onTap: course.rightsLeft > 0
                ? () => _markToday(course, 'gelmedim')
                : null,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, Color color, {VoidCallback? onTap}) {
    final bool disabled = onTap == null;
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.12),
          disabledBackgroundColor: color.withValues(alpha: 0.06),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: color.withValues(alpha: disabled ? 0.12 : 0.3),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: disabled ? 0.35 : 1.0),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.44, // 0.04em @ 11px
          ),
        ),
      ),
    );
  }

  Widget _buildMarkedRow(String mark, Course course, Color textColor) {
    late Color c;
    late String label;
    switch (mark) {
      case 'gelmedim':
        c = kVibrantRed;
        label = "BUGÜN: GELMEDİM";
        break;
      case 'geldim':
        c = kSuccessGreen;
        label = "BUGÜN: GELDİM";
        break;
      default:
        c = textColor.withValues(alpha: 0.6);
        label = "BUGÜN: İPTAL";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _undoToday(course),
          child: Text(
            "GERİ AL",
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) => CustomPaint(
                  painter: _AuroraBackgroundPainter(phase: _waveController.value),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const Spacer(flex: 3),
              // App logo
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kVibrantRed, Color(0xFF9B1D1D)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: kVibrantRed.withValues(alpha: 0.38),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),
              Text(
                'Devamsızlık\nTakip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Derslerini yönet, devamsızlığını kontrol et.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.45),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              _featureItem(Icons.check_circle_outline_rounded, 'Devamsızlık Takibi', 'Günlük yoklama ve hak yönetimi', textColor),
              const SizedBox(height: 14),
              _featureItem(Icons.calendar_month_outlined, 'Ders Takvimi', 'Aylık görünümle planla', textColor),
              const SizedBox(height: 14),
              _featureItem(Icons.assignment_outlined, 'Sınav Planlama', 'Notlar ve hatırlatıcılarla hazırlan', textColor),
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_pulseController.value);
                  return Container(
                    width: 88,
                    height: 88,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.lerp(
                          textColor.withValues(alpha: 0.15),
                          kVibrantRed.withValues(alpha: 0.88),
                          t,
                        )!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kVibrantRed.withValues(alpha: 0.06 + 0.18 * t),
                          blurRadius: 18 + 14 * t,
                          spreadRadius: 1 + 2 * t,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: kVibrantRed,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _addCourse,
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'DERS EKLE',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.2,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kVibrantRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kVibrantRed, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hoş geldiniz ekranı arka planı: yavaşça süzülen iki bordo ışık huzmesi.
/// Sadece birkaç gradyan dikdörtgeni çizer; performansı yüksektir.
class _AuroraBackgroundPainter extends CustomPainter {
  final double phase; // 0..1 sürekli ilerleyen değer
  _AuroraBackgroundPainter({required this.phase});

  // Koyu bordo tonu.
  static const Color _bordo = Color(0xFF7A1E2E);

  @override
  void paint(Canvas canvas, Size size) {
    const tau = 2 * 3.1415926;

    // 1) Üst-merkezden gelen sabit, yumuşak bordo aydınlanma.
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.7),
        radius: 1.1,
        colors: [
          _bordo.withValues(alpha: 0.22),
          _bordo.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, topGlow);

    // 2) Çapraz olarak yavaşça gezinen ışık huzmesi (süzülme hissi).
    final sweep = (math.sin(phase * tau) + 1) / 2; // 0..1 ileri-geri yumuşak
    final cx = size.width * (0.2 + 0.6 * sweep);
    final cy = size.height * (0.35 + 0.1 * sweep);
    final beam = Paint()
      ..shader = RadialGradient(
        colors: [
          _bordo.withValues(alpha: 0.20),
          _bordo.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(cx, cy),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawRect(Offset.zero & size, beam);

    // 3) Alt köşede ikinci, daha sönük huzme: derinlik katar.
    final cx2 = size.width * (0.85 - 0.5 * sweep);
    final beam2 = Paint()
      ..shader = RadialGradient(
        colors: [
          _bordo.withValues(alpha: 0.14),
          _bordo.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(cx2, size.height * 0.82),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, beam2);
  }

  @override
  bool shouldRepaint(_AuroraBackgroundPainter old) => old.phase != phase;
}
