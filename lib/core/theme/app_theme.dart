import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın kırmızı vurgu rengi. Yalnızca aktif durumlar, CTA butonları
/// ve kritik göstergeler için kullanılır. Koyu, doygun bir kırmızı.
const Color kVibrantRed = Color(0xFFD62828);

/// Daha koyu kırmızı: kritik HAK göstergesi (devamsızlık 2'ye düşünce).
const Color kRedDeep = Color(0xFFB81C1C);

/// Başarı yeşili: GELDİM ve olumlu durumlar.
const Color kSuccessGreen = Color(0xFF34C759);

/// Sınav ekranının ayırt edici vurgu rengi (indigo). Ders takvimini (kırmızı)
/// sınav takviminden görsel olarak ayırmak için kullanılır.
const Color kExamAccent = Color(0xFF5B5BD6);

// ---------- Katmanlı koyu yüzeyler ----------
/// Nötr, siyaha dönük tonlar (mavi/mor tını yok).
/// Ana zemin.
const Color kBgDark = Color(0xFF080808);

/// Kartlar.
const Color kCardDark = Color(0xFF121212);

/// Üst katman elemanlar (tab bar zemini, ikon butonlar, modallar).
const Color kElevatedDark = Color(0xFF1C1C1C);

// ---------- Light tema yüzeyleri ----------
const Color kBgLight = Color(0xFFF5F5F7);
const Color kCardLight = Color(0xFFFFFFFF);
const Color kTextPrimaryLight = Color(0xFF1A1A1A);
const Color kTextSecondaryLight = Color(0xFF6B6B6B);
const Color kTextTertiaryLight = Color(0xFFA0A0A0);

/// Üst katman yüzey rengi (temaya duyarlı).
Color elevatedSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? kElevatedDark
        : kCardLight;

/// Kart kenarlığı: koyu temada hafif beyaz, açık temada hafif siyah.
Color cardBorderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

/// Kart gölgesi: yalnızca açık temada yumuşak bir gölge.
List<BoxShadow>? cardShadow(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ];

/// Bölüm etiketi stili ("BUGÜN", "TÜM DERSLER"...): küçük, kalın,
/// geniş harf aralıklı, soluk — zarif bir etiket hissi.
TextStyle sectionLabelStyle(Color textColor) => TextStyle(
      color: textColor.withValues(alpha: 0.45),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.88, // 0.08em @ 11px
    );

/// Ana başlık stili ("Sınav Takvimi", "Ders Takvimi"...).
TextStyle screenTitleStyle(Color textColor) => TextStyle(
      color: textColor,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );

/// Ana başlıkların altındaki ince kırmızı vurgu çizgisi.
Widget titleUnderline() => Container(
      width: 20,
      height: 2,
      decoration: BoxDecoration(
        color: kVibrantRed,
        borderRadius: BorderRadius.circular(1),
      ),
    );

/// "4 HAK" pill rozeti. Yuvarlak/çember yerine sade, modern bir badge.
/// 3+ hak → nötr (temaya göre beyaz/koyu) yazı. 2 ve altı → koyu kırmızı.
class RightsBadge extends StatelessWidget {
  final int rights;
  const RightsBadge({super.key, required this.rights});

  @override
  Widget build(BuildContext context) {
    final Color neutral = Theme.of(context).colorScheme.onSurface;

    late final Color bg;
    late final Color border;
    late final Color fg;
    if (rights >= 3) {
      bg = neutral.withValues(alpha: 0.06);
      border = neutral.withValues(alpha: 0.12);
      fg = neutral;
    } else {
      bg = kVibrantRed.withValues(alpha: 0.12);
      border = kVibrantRed.withValues(alpha: 0.25);
      fg = kRedDeep;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$rights HAK",
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Tüm ekran geçişleri için yumuşak, iOS tarzı kaydırmalı animasyon.
const PageTransitionsTheme kPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
  },
);

/// Tema durumunu tüm uygulamaya yayan global denetleyici.
/// main.dart bunu ValueListenableBuilder ile dinler; Ayarlar ekranı günceller.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

const String _kThemeKey = 'is_dark_mode';

/// runApp'ten önce çağrılır: kayıtlı tema tercihini yükler.
Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool(_kThemeKey) ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

/// Ayarlar ekranından çağrılır: temayı değiştirir ve kalıcı yapar.
Future<void> setDarkMode(bool isDark) async {
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kThemeKey, isDark);
}

bool get isDarkModeActive => themeNotifier.value == ThemeMode.dark;

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBgDark,
    canvasColor: kBgDark,
    cardColor: kCardDark,
    dividerColor: Colors.white.withValues(alpha: 0.06),
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: kVibrantRed,
      surface: kBgDark,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    pageTransitionsTheme: kPageTransitions,
    // InkSparkle shader bazı cihazlarda takılma yapıyor; klasik ripple akıcı.
    splashFactory: InkRipple.splashFactory,
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kBgLight,
    canvasColor: kBgLight,
    cardColor: kCardLight,
    dividerColor: Colors.black.withValues(alpha: 0.06),
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: kTextPrimaryLight,
      secondary: kVibrantRed,
      surface: kBgLight,
      onSurface: kTextPrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: kTextPrimaryLight,
    ),
    pageTransitionsTheme: kPageTransitions,
    splashFactory: InkRipple.splashFactory,
  );
}
