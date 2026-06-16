import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// "SingleTickerProviderStateMixin" animasyonun telefonun ekran yenileme hızıyla (60fps/120fps) senkronize çalışmasını sağlar
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final String _appName = "DEVAMSIZLIK TAKİP";

  @override
  void initState() {
    super.initState();
    
    // Animasyon motorunu kuruyoruz (2.5 saniyede bir tur atacak)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(); // Sürekli tekrarla

    // 3.5 Saniye sonra ana ekrana geçiş yap
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      _controller.stop(); // Geçiş yaparken animasyonu durdur
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.04, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Ekran kapanırken belleği temizle (Mühendislik kuralı)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        
            
            // Harf harf parlama efekti için AnimatedBuilder kullanıyoruz
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_appName.length, (index) {
                    // Animasyonun o anki değerine göre hangi harfin parlayacağını hesaplıyoruz
                    double glowPosition = _controller.value * (_appName.length + 5); 
                    double distance = (glowPosition - index).abs();
                    
                    // Parlaklık şiddeti (Yakın olan harf çok parlak, uzak olan soluk)
                    double intensity = 1.0 - (distance * 0.4);
                    intensity = intensity.clamp(0.2, 1.0); // En az %20, en çok %100 parlaklık

                    return Text(
                      _appName[index],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.white.withValues(alpha: intensity),
                        shadows: intensity > 0.8 
                            ? [const Shadow(color: Colors.white, blurRadius: 15)] // Parlayan harfin etrafına ışık huzmesi
                            : [],
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 50),
            
            // Profesyonel 3 nokta yükleme animasyonu (Lineer ve sade)
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: kElevatedDark,
                color: kVibrantRed,
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}