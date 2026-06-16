import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'features/splash_screen.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Saat ve takvim motorunu başlat
  tz_data.initializeTimeZones();

  // 🚀 TÜRKİYE SAATİ GARANTİSİ: Sistemi İstanbul saatine sabitliyoruz!
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  // 2. Bildirim motorumuzu başlat
  await NotificationService.initialize();

  // 3. Kayıtlı tema tercihini yükle
  await loadTheme();

  // 4. Türkçe tarih biçimlerini (ay/gün adları) hazırla
  await initializeDateFormatting('tr_TR', null);

  runApp(const DevamsizlikTakipApp());
}

class DevamsizlikTakipApp extends StatelessWidget {
  const DevamsizlikTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Devamsızlık Takip',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          locale: const Locale('tr', 'TR'),
          supportedLocales: const [Locale('tr', 'TR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
