import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/course_model.dart';
import '../../core/models/term.dart';
import '../../core/services/holiday_service.dart';
import '../../core/theme/app_theme.dart';

const List<String> _kDayNames = [
  "Pazartesi",
  "Salı",
  "Çarşamba",
  "Perşembe",
  "Cuma",
  "Cumartesi",
  "Pazar",
];

/// Ders takvimi (gömülü). Aktif döneme ait dersleri aylık takvimde gösterir;
/// bir güne dokununca o günün derslerini ve kalan hakları listeler.
class CalendarScreen extends StatefulWidget {
  final List<Course> courses;
  final Term activeTerm;
  const CalendarScreen({
    super.key,
    required this.courses,
    required this.activeTerm,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Performans: renk haritası her marker çiziminde değil, ders listesi
  // değiştiğinde bir kez hesaplanır.
  Map<String, Color> _courseColorMap = {};
  List<Course> _termCourses = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rebuildCaches();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courses != widget.courses ||
        oldWidget.activeTerm.id != widget.activeTerm.id) {
      _rebuildCaches();
    }
  }

  /// Dönemdeki her derse paletten sırayla farklı bir renk atar.
  /// Hash yerine sıra kullanıldığı için renkler çakışmaz (palet 8 renk).
  void _rebuildCaches() {
    _termCourses = widget.courses
        .where((c) => c.term == widget.activeTerm.id)
        .toList();
    final sorted = List<Course>.from(_termCourses)
      ..sort((a, b) => a.id.compareTo(b.id));
    final map = <String, Color>{};
    for (var i = 0; i < sorted.length; i++) {
      final hex = Course.colorPalette[i % Course.colorPalette.length];
      map[sorted[i].id] = Color(int.parse('0xFF${hex.replaceFirst('#', '')}'));
    }
    _courseColorMap = map;
  }

  /// O gün işlenen dersler. Dönem dışı veya resmi tatil ise boş döner.
  List<Course> _coursesOn(DateTime day) {
    if (!widget.activeTerm.contains(day)) return [];
    if (HolidayService.isHoliday(day)) return [];
    final name = _kDayNames[day.weekday - 1];
    final list = _termCourses.where((c) => c.days.contains(name)).toList()
      ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    return list;
  }

  /// Gün için ders renklerini döndürür: her dersin kendi sabit rengi.
  List<Color> _getAllCourseColors(DateTime day) {
    final list = _coursesOn(day);
    if (list.isEmpty) return [];
    return list.map((c) => _courseColorMap[c.id] ?? kVibrantRed).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final selectedList = _coursesOn(_selectedDay);

    return Column(
      children: [
        _calendarHeader("Ders Takvimi", textColor),
        _calendarCard(
          context,
          textColor,
          TableCalendar<Course>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          locale: 'tr_TR',
          selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          // Yatay kaydırma sekme geçişine (PageView) bırakıldı; ay değişimi
          // başlıktaki oklarla yapılır. Jest çakışması ve kasma biter.
          availableGestures: AvailableGestures.none,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
            rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: textColor.withValues(alpha: 0.3),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: textColor.withValues(alpha: 0.3),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: TextStyle(color: textColor.withValues(alpha: 0.8)),
            weekendTextStyle: TextStyle(color: textColor.withValues(alpha: 0.8)),
            // Bugün: 36px kırmızı çember.
            todayDecoration: const BoxDecoration(
              color: kVibrantRed,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            // Seçili gün: hafif kırmızı tonlu yüzey + kırmızı yazı.
            selectedDecoration: BoxDecoration(
              color: kVibrantRed.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: kVibrantRed,
              fontWeight: FontWeight.w600,
            ),
            cellMargin: const EdgeInsets.all(5),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              // Tatil varsa "T" göster
              if (HolidayService.isHoliday(day)) {
                return Positioned(
                  bottom: 4,
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: const Color(0xFF2F80ED),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              // O günün dersleri var mı?
              final colors = _getAllCourseColors(day);
              if (colors.isEmpty) return null;

              // Ders noktaları sayının ALTINDA, 3'erli iki sıra halinde
              // gösterilir (üstte 3, altta 3 → bir günde en fazla 6 ders).
              final displayColors = colors.take(6).toList();
              final topRow = displayColors.take(3).toList();
              final bottomRow = displayColors.skip(3).take(3).toList();

              Widget dotRow(List<Color> rowColors) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: rowColors
                    .map(
                      (color) => Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              );

              return Positioned(
                bottom: 1,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    dotRow(topRow),
                    if (bottomRow.isNotEmpty) dotRow(bottomRow),
                  ],
                ),
              );
            },
          ),
        ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildDayPanel(selectedList, textColor)),
      ],
    );
  }

  /// Sayfa başlığı: ad + altında ince kırmızı vurgu + dönem rozeti.
  Widget _calendarHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: screenTitleStyle(textColor)),
              const SizedBox(height: 6),
              titleUnderline(),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kVibrantRed.withValues(alpha: 0.1),
              border: Border.all(color: kVibrantRed.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.activeTerm.label,
              style: const TextStyle(
                color: kVibrantRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Takvimi ince çerçeveli, yuvarlak köşeli bir kart içine alır.
  Widget _calendarCard(BuildContext context, Color textColor, Widget child) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorderColor(context)),
        boxShadow: cardShadow(context),
      ),
      child: child,
    );
  }

  Widget _buildDayPanel(List<Course> selectedList, Color textColor) {
    final holiday = HolidayService.nameFor(_selectedDay);
    if (holiday != null) {
      return _centerInfo(
        Icons.celebration_outlined,
        "Resmi Tatil",
        holiday,
        const Color(0xFF2F80ED),
        textColor,
      );
    }
    if (!widget.activeTerm.contains(_selectedDay)) {
      return _centerInfo(
        Icons.event_busy_outlined,
        "Dönem Dışı",
        "Bu tarih ${widget.activeTerm.label} dönemine ait değil.",
        textColor.withValues(alpha: 0.4),
        textColor,
      );
    }
    if (selectedList.isEmpty) {
      return _centerInfo(
        Icons.free_breakfast_outlined,
        "Ders Yok",
        "Bu gün için planlı bir ders bulunmuyor.",
        textColor.withValues(alpha: 0.35),
        textColor,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: selectedList.length,
      itemBuilder: (context, i) => _dayCourseTile(selectedList[i], textColor),
    );
  }

  Widget _centerInfo(
    IconData icon,
    String title,
    String subtitle,
    Color accent,
    Color textColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: accent),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.45),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCourseTile(Course course, Color textColor) {
    final String mark = course.markFor(_selectedDay) ?? '';
    // Yan çizgi her zaman dersin takvimdeki sabit rengini taşır; kritik
    // durumda kırmızıya dönmez (kalan hak rozeti zaten uyarıyor).
    final Color courseDot = _courseColorMap[course.id] ?? kVibrantRed;
    final Color cardBg = Theme.of(context).cardColor;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor(context)),
        boxShadow: cardShadow(context),
      ),
      child: Row(
        children: [
          // Sol kenarda dersin rengini taşıyan ince vurgu çubuğu.
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: courseDot,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.time.isEmpty ? "Saat belirtilmedi" : course.time,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (mark.isNotEmpty) ...[
            _markChip(mark, textColor),
            const SizedBox(width: 10),
          ],
          RightsBadge(rights: course.rightsLeft),
        ],
      ),
    );
  }

  Widget _markChip(String mark, Color textColor) {
    late Color c;
    late String label;
    switch (mark) {
      case 'gelmedim':
        c = kVibrantRed;
        label = 'GELMEDİM';
        break;
      case 'geldim':
        c = kSuccessGreen;
        label = 'GELDİM';
        break;
      default:
        c = textColor.withValues(alpha: 0.5);
        label = 'İPTAL';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
