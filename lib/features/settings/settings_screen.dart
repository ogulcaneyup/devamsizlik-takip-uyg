import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/term.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Term _activeTerm = Term.current();
  bool _termChanged = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final term = await StorageService.getActiveTerm();
    if (!mounted) return;
    setState(() {
      _activeTerm = term;
    });
  }

  Future<void> _pickTerm() async {
    int year = _activeTerm.year;
    TermSeason season = _activeTerm.season;
    DateTime start = _activeTerm.effectiveStart;
    DateTime end = _activeTerm.effectiveEnd;
    final cs = Theme.of(context).colorScheme;

    String fmt(DateTime d) => "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";

    final Term? result = await showDialog<Term>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            Widget dateRow(String label, DateTime value, ValueChanged<DateTime> onPick) {
              return InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: value,
                    firstDate: DateTime(year - 1),
                    lastDate: DateTime(year + 2),
                  );
                  if (picked != null) setLocal(() => onPick(picked));
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                      Text(fmt(value), style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text("Dönem Seç", style: TextStyle(color: cs.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: Icon(Icons.remove, color: cs.onSurface), onPressed: () => setLocal(() => year--)),
                        Text(year.toString(), style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w300)),
                        IconButton(icon: Icon(Icons.add, color: cs.onSurface), onPressed: () => setLocal(() => year++)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: TermSeason.values.map((s) {
                        final selected = s == season;
                        final label = s == TermSeason.guz ? 'Güz' : 'Bahar';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            selectedColor: kVibrantRed,
                            labelStyle: TextStyle(color: selected ? Colors.white : cs.onSurface),
                            backgroundColor: cs.onSurface.withValues(alpha: 0.06),
                            onSelected: (_) => setLocal(() {
                              season = s;
                              // sezon değişince varsayılan tarihlere dön
                              final base = Term(year: year, season: s);
                              start = base.defaultStart;
                              end = base.defaultEnd;
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                    dateRow("Başlangıç", start, (d) => start = d),
                    dateRow("Bitiş", end, (d) => end = d),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
                TextButton(
                  onPressed: () => Navigator.pop(context, Term(year: year, season: season, startDate: start, endDate: end)),
                  child: Text("Kaydet", style: TextStyle(color: kVibrantRed)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await StorageService.setActiveTerm(result);
      if (!mounted) return;
      setState(() {
        _activeTerm = result;
        _termChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = cs.onSurface;
    final Color cardColor = Theme.of(context).cardColor;
    final Color borderColor = cardBorderColor(context);

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
            onPressed: () => Navigator.pop(context, _termChanged),
          ),
          title: Text("AYARLAR", style: TextStyle(color: textColor.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.96)),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text("Ayarlar", style: screenTitleStyle(textColor)),
            const SizedBox(height: 8),
            titleUnderline(),
            const SizedBox(height: 36),

            _sectionLabel("DÖNEM", textColor),
            const SizedBox(height: 12),
            _tappableCard(
              cardColor, borderColor,
              icon: Icons.school_outlined, iconColor: kVibrantRed, textColor: textColor,
              title: "Aktif Dönem", subtitle: _activeTerm.label,
              trailing: Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.4)),
              onTap: _pickTerm,
            ),

            const SizedBox(height: 32),
            _sectionLabel("GÖRÜNÜM", textColor),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: cardShadow(context)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: textColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                    child: Icon(isDarkModeActive ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text("Karanlık Tema", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  Switch(
                    value: isDarkModeActive,
                    onChanged: (v) async {
                      await setDarkMode(v);
                      if (mounted) setState(() {});
                    },
                    activeThumbColor: kVibrantRed,
                    activeTrackColor: kVibrantRed.withValues(alpha: 0.3),
                    inactiveThumbColor: textColor.withValues(alpha: 0.5),
                    inactiveTrackColor: cardColor,
                  )
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _sectionLabel(String text, Color textColor) =>
      Text(text, style: sectionLabelStyle(textColor));

  Widget _tappableCard(Color cardColor, Color borderColor,
      {required IconData icon, required Color iconColor, required Color textColor, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: cardShadow(context)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 13)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
