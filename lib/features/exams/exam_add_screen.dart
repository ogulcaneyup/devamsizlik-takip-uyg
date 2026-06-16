import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/models/course_model.dart';
import '../../core/models/exam_model.dart';
import '../../core/models/term.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

/// Sınav ekleme: aktif dönem derslerini sürükleyip takvimde bir güne bırak;
/// açılan alt panelde saat / yanına al / not gir, kaydet.
class ExamAddScreen extends StatefulWidget {
  final List<Course> courses;
  final List<Exam> exams;
  final Term activeTerm;
  const ExamAddScreen({
    super.key,
    required this.courses,
    required this.exams,
    required this.activeTerm,
  });

  @override
  State<ExamAddScreen> createState() => _ExamAddScreenState();
}

class _ExamAddScreenState extends State<ExamAddScreen> {
  late List<Exam> _workingExams;
  DateTime _focusedDay = DateTime.now();
  DateTime? _dragOverDay;

  final _bringCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _workingExams = List<Exam>.from(widget.exams);
  }

  @override
  void dispose() {
    _bringCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<Course> get _termCourses =>
      widget.courses.where((c) => c.term == widget.activeTerm.id).toList();

  List<Exam> _examsOn(DateTime day) =>
      _workingExams.where((e) => isSameDay(e.date, day)).toList();

  TimeOfDay? _parseTime(String hhmm) {
    if (hhmm.isEmpty || !hhmm.contains(':')) return null;
    final p = hhmm.split(':');
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p.length > 1 ? p[1] : '0');
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmt(TimeOfDay? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _onDropCourse(Course course, DateTime day) {
    setState(() {
      _dragOverDay = null;
      _focusedDay = day;
    });
    _openExamSheet(course, day);
  }

  /// Bırakılan ders için sınav detaylarını alt sayfada (modal) topla.
  Future<void> _openExamSheet(Course course, DateTime day) async {
    TimeOfDay? time = _parseTime(course.time);
    _bringCtrl.clear();
    _notesCtrl.clear();
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    final result = await showModalBottomSheet<Exam>(
      context: context,
      isScrollControlled: true,
      backgroundColor: elevatedSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 24 + MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${course.name} · ${day.day}.${day.month}.${day.year}",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: sheetCtx,
                          initialTime:
                              time ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) setSheet(() => time = picked);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: textColor.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              time == null ? "Sınav saati" : _fmt(time),
                              style: TextStyle(
                                color: time == null
                                    ? textColor.withValues(alpha: 0.4)
                                    : textColor,
                                fontSize: 15,
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: textColor.withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sheetField(
                      _bringCtrl,
                      "Yanına al (hesap makinesi, kalem...)",
                      textColor,
                    ),
                    const SizedBox(height: 12),
                    _sheetField(
                      _notesCtrl,
                      "Not (önceki sınav, konular...)",
                      textColor,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final existing = _workingExams.where(
                            (e) =>
                                e.courseName == course.name &&
                                isSameDay(e.date, day) &&
                                e.term == widget.activeTerm.id,
                          );
                          if (existing.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${course.name} için bu güne zaten sınav eklendi.",
                                ),
                                backgroundColor: kVibrantRed,
                              ),
                            );
                            Navigator.pop(sheetCtx);
                            return;
                          }

                          final exam = Exam(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            courseId: course.id,
                            courseName: course.name,
                            date: DateTime(day.year, day.month, day.day),
                            time: _fmt(time),
                            bringList: _bringCtrl.text.trim(),
                            notes: _notesCtrl.text.trim(),
                            term: widget.activeTerm.id,
                          );
                          Navigator.pop(sheetCtx, exam);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kVibrantRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "SINAVI KAYDET",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result is Exam) {
      setState(() => _workingExams.add(result));
      await StorageService.saveExams(_workingExams);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${result.courseName} sınavı eklendi.")),
      );
    }
  }

  Widget _sheetField(
    TextEditingController controller,
    String hint,
    Color textColor,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 15),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 14),
        filled: true,
        fillColor: textColor.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = cs.onSurface;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context, _workingExams),
        ),
        title: Text(
          "SINAV EKLE",
          style: TextStyle(
            color: textColor.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.96,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dersi bir güne sürükle",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          _buildCourseStrip(textColor),
          Expanded(child: _buildCalendar(textColor)),
        ],
      ),
    );
  }

  Widget _buildCourseStrip(Color textColor) {
    final courses = _termCourses;
    if (courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Bu dönemde ders yok. Önce ders ekle.",
          style: TextStyle(color: textColor.withValues(alpha: 0.4)),
        ),
      );
    }
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, i) {
          final c = courses[i];
          final chip = _courseChip(c, textColor);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Draggable<Course>(
              data: c,
              feedback: Material(
                color: Colors.transparent,
                child: _courseChip(c, textColor, dragging: true),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: chip),
              child: chip,
            ),
          );
        },
      ),
    );
  }

  Widget _courseChip(Course c, Color textColor, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? kVibrantRed : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dragging ? kVibrantRed : textColor.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        c.name,
        style: TextStyle(
          color: dragging ? Colors.white : textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCalendar(Color textColor) {
    return TableCalendar<Exam>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      onPageChanged: (f) => setState(() => _focusedDay = f),
      eventLoader: _examsOn,
      startingDayOfWeek: StartingDayOfWeek.monday,
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
          color: textColor.withValues(alpha: 0.5),
          fontSize: 12,
        ),
        weekendStyle: TextStyle(
          color: textColor.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      calendarBuilders: CalendarBuilders<Exam>(
        defaultBuilder: (context, day, events) => _calendarCell(day, textColor),
        todayBuilder: (context, day, events) =>
            _calendarCell(day, textColor, isToday: true),
        outsideBuilder: (context, day, events) =>
            _calendarCell(day, textColor, isOutside: true),
        selectedBuilder: (context, day, events) =>
            _calendarCell(day, textColor),
        markerBuilder: (context, day, events) => null,
      ),
    );
  }

  Widget _calendarCell(
    DateTime day,
    Color textColor, {
    bool isToday = false,
    bool isOutside = false,
  }) {
    return DragTarget<Course>(
      onWillAcceptWithDetails: (details) {
        final isCurrentlyOver =
            _dragOverDay != null && isSameDay(_dragOverDay, day);
        if (!isCurrentlyOver) {
          setState(() => _dragOverDay = day);
        }
        return true;
      },
      onLeave: (_) {
        if (_dragOverDay != null && isSameDay(_dragOverDay, day)) {
          setState(() => _dragOverDay = null);
        }
      },
      onAcceptWithDetails: (details) => _onDropCourse(details.data, day),
      builder: (context, candidate, rejected) {
        final isOver = _dragOverDay != null && isSameDay(_dragOverDay, day);
        final hasExam = _examsOn(day).isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isOver
                ? kVibrantRed
                : (hasExam
                      ? kVibrantRed.withValues(alpha: 0.15)
                      : Colors.transparent),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: textColor.withValues(alpha: 0.3))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isOver
                  ? Colors.white
                  : textColor.withValues(alpha: isOutside ? 0.25 : 0.85),
              fontWeight: hasExam ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
