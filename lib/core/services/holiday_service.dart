/// Türkiye resmi tatilleri.
///
/// Sabit (her yıl aynı tarih) milli bayramlar koddan hesaplanır.
/// Dini bayramlar (Ramazan / Kurban) ay takvimine göre kaydığından
/// 2025–2027 için resmi (yaklaşık) tarihler elle gömülmüştür; bu yıllardan
/// sonrası için yalnızca sabit tatiller gösterilir (güncelleme gerekir).
class HolidayService {
  /// Sabit milli bayramlar: (ay, gün) -> ad.
  static const Map<String, String> _fixed = {
    '1-1': 'Yılbaşı',
    '4-23': '23 Nisan Ulusal Egemenlik ve Çocuk Bayramı',
    '5-1': 'Emek ve Dayanışma Günü',
    '5-19': '19 Mayıs Gençlik ve Spor Bayramı',
    '7-15': 'Demokrasi ve Milli Birlik Günü',
    '8-30': '30 Ağustos Zafer Bayramı',
    '10-29': 'Cumhuriyet Bayramı',
  };

  /// Dini bayram aralıkları (gün dahil). Yıl -> liste.
  static const Map<int, List<_Range>> _religious = {
    2025: [
      _Range(3, 30, 4, 1, 'Ramazan Bayramı'),
      _Range(6, 6, 6, 9, 'Kurban Bayramı'),
    ],
    2026: [
      _Range(3, 20, 3, 22, 'Ramazan Bayramı'),
      _Range(5, 27, 5, 30, 'Kurban Bayramı'),
    ],
    2027: [
      _Range(3, 10, 3, 12, 'Ramazan Bayramı'),
      _Range(5, 16, 5, 19, 'Kurban Bayramı'),
    ],
  };

  /// O güne ait tatil adı, yoksa null.
  static String? nameFor(DateTime d) {
    final fixed = _fixed['${d.month}-${d.day}'];
    if (fixed != null) return fixed;

    final ranges = _religious[d.year];
    if (ranges != null) {
      for (final r in ranges) {
        if (r.contains(d)) return r.name;
      }
    }
    return null;
  }

  static bool isHoliday(DateTime d) => nameFor(d) != null;
}

class _Range {
  final int startMonth, startDay, endMonth, endDay;
  final String name;
  const _Range(this.startMonth, this.startDay, this.endMonth, this.endDay, this.name);

  bool contains(DateTime d) {
    final cur = DateTime(d.year, d.month, d.day);
    final s = DateTime(d.year, startMonth, startDay);
    final e = DateTime(d.year, endMonth, endDay);
    return !cur.isBefore(s) && !cur.isAfter(e);
  }
}
