import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/exam_model.dart';
import '../../core/models/term.dart';
import '../../core/theme/app_theme.dart';

/// Sınav takvimi (gömülü). Kayıtlı sınavları aylık takvimde gösterir;
/// bir güne dokununca o günün sınavlarını listeler, silmeye izin verir.
class ExamCalendarScreen extends StatefulWidget {
  final List<Exam> exams;
  final Term activeTerm;
  final ValueChanged<Exam> onDelete;
  const ExamCalendarScreen({
    super.key,
    required this.exams,
    required this.activeTerm,
    required this.onDelete,
  });

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _currentTab = 0; // 0: Takvim, 1: Ders Notları

  @override
  bool get wantKeepAlive => true;

  /// O gün sınavlarının dersleri döndür (renkler için)
  List<Exam> _examsOn(DateTime day) =>
      widget.exams
          .where(
            (e) => isSameDay(e.date, day) && e.term == widget.activeTerm.id,
          )
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  List<Exam> _examsForCourse(String courseName) => widget.exams
      .where(
        (e) => e.courseName == courseName && e.term == widget.activeTerm.id,
      )
      .toList();

  List<String> _getAllCourses() =>
      widget.exams
          .where((e) => e.term == widget.activeTerm.id)
          .map((e) => e.courseName)
          .toSet()
          .toList()
        ..sort();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final selected = _examsOn(_selectedDay);

    return Column(
      children: [
        _examHeader("Sınav Takvimi", textColor),
        _buildTabButtons(textColor),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: _currentTab == 0
                ? KeyedSubtree(
                    key: const ValueKey('cal'),
                    child: _buildCalendarTab(selected, textColor),
                  )
                : KeyedSubtree(
                    key: const ValueKey('notes'),
                    child: _buildNotesTab(textColor),
                  ),
          ),
        ),
      ],
    );
  }

  /// Sayfa başlığı: ad + ince kırmızı vurgu + dönem rozeti.
  Widget _examHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              color: kExamAccent.withValues(alpha: 0.1),
              border: Border.all(color: kExamAccent.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.activeTerm.label,
              style: const TextStyle(
                color: kExamAccent,
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

  /// Pill (segment) tarzı sekme seçici: aktif sekme hafif kırmızı tonlu.
  Widget _buildTabButtons(Color textColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: elevatedSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor(context)),
      ),
      child: Row(
        children: [
          _tabPill('TAKVİM', 0, textColor),
          _tabPill('DERS NOTLARI', 1, textColor),
        ],
      ),
    );
  }

  Widget _tabPill(String label, int index, Color textColor) {
    final bool active = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? kExamAccent.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? kExamAccent : textColor.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.88,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTab(List<Exam> selected, Color textColor) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorderColor(context)),
            boxShadow: cardShadow(context),
          ),
          child: TableCalendar<Exam>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          locale: 'tr_TR',
          selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
          onDaySelected: (s, f) => setState(() {
            _selectedDay = s;
            _focusedDay = f;
          }),
          eventLoader: _examsOn,
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
            markerDecoration: BoxDecoration(
              color: kExamAccent.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            // Bugün: kırmızı çember.
            todayDecoration: const BoxDecoration(
              color: kExamAccent,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            // Seçili gün: hafif kırmızı tonlu yüzey + kırmızı yazı.
            selectedDecoration: BoxDecoration(
              color: kExamAccent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: kExamAccent,
              fontWeight: FontWeight.w600,
            ),
            cellMargin: const EdgeInsets.all(5),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final count = _examsOn(day).length;
              if (count == 0) return null;
              // Sayının altında, sınav sayısı kadar (max 4) kırmızı nokta.
              return Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    count > 4 ? 4 : count,
                    (_) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: kExamAccent.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: selected.isEmpty
              ? _centerInfo(
                  Icons.event_available_outlined,
                  "Sınav Yok",
                  "Bu gün için planlı bir sınav bulunmuyor.",
                  textColor,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  itemCount: selected.length,
                  itemBuilder: (context, i) =>
                      _examTile(selected[i], textColor),
                ),
        ),
      ],
    );
  }

  /// İkonlu, ortalanmış bilgi/boş durum gösterimi.
  Widget _centerInfo(
    IconData icon,
    String title,
    String subtitle,
    Color textColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: textColor.withValues(alpha: 0.3)),
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

  Widget _buildNotesTab(Color textColor) {
    final courses = _getAllCourses();

    if (courses.isEmpty) {
      return _centerInfo(
        Icons.note_alt_outlined,
        "Sınav Notu Yok",
        "Sağ üstteki + ile sınav ekleyip notlarını buradan takip et.",
        textColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      physics: const ClampingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final course = courses.elementAt(i);
        final exams = _examsForCourse(course);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor(context)),
            boxShadow: cardShadow(context),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        course,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kExamAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${exams.length} sınav",
                        style: const TextStyle(
                          color: kExamAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: textColor.withValues(alpha: 0.05),
                indent: 14,
                endIndent: 14,
              ),
              ...exams.map((exam) => _noteItem(exam, textColor)),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _noteItem(Exam exam, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${exam.date.day}.${exam.date.month}.${exam.date.year}${exam.time.isNotEmpty ? " · ${exam.time}" : ""}",
                  style: TextStyle(
                    color: kExamAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: textColor.withValues(alpha: 0.4),
                  size: 18,
                ),
                onPressed: () => widget.onDelete(exam),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (exam.bringList.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "📋 Yanına Al: ${exam.bringList}",
              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
          if (exam.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "📝 Notlar: ${exam.notes}",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _examTile(Exam exam, Color textColor) {
    final Color cardBg = Theme.of(context).cardColor;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor(context)),
        boxShadow: cardShadow(context),
      ),
      child: Row(
        children: [
          // Sol kenarda kırmızı vurgu çubuğu.
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: kExamAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.courseName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exam.time.isEmpty
                      ? "Saat belirtilmedi"
                      : "Saat: ${exam.time}",
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (exam.bringList.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Yanına al: ${exam.bringList}",
                    style: TextStyle(
                      color: kExamAccent.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
                if (exam.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    exam.notes,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: textColor.withValues(alpha: 0.4),
              size: 20,
            ),
            onPressed: () => widget.onDelete(exam),
          ),
        ],
      ),
    );
  }
}
