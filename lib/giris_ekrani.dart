import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kurye_kayit.dart';
import 'kurye_giris.dart';
import 'isletme_giris.dart';
import 'isletme_kayit.dart';
import 'kurye_giris_yapinca.dart';
import 'isletme_panel_2_fixed.dart';
import 'services/auth_service.dart';

// MyApp uygulama girişi artık lib/main.dart dosyasında tanımlı

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Total duration of the animation
    );

    // Breathing animation - scales between 0.9 and 1.1 of original size
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.9), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    // Repeat the breathing animation
    _controller.repeat(reverse: true);

    // Attempt auto-login immediately
    _attemptAutoLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _attemptAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (remember && user != null) {
        final authService = AuthService();
        final role = await authService.getUserRole(user.uid);
        if (!mounted) return;
        if (role == 'courier') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const KuryeEkrani()),
          );
          return;
        } else if (role == 'business') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const IsletmePaneli()),
          );
          return;
        }
      } else if (user != null && !remember) {
        // If user exists but didn't opt-in to remember, sign out silently
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}

    // Fallback: go to role selection after short delay
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue],
            stops: [0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Widget _buildRegisterButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white, // Beyaz arka plan
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Color(0xFF1976D2), // Koyu mavi yazı rengi
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9), Color(0xFF64B5F6)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  // Logo and Welcome Section
                  Container(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Column(
                      children: [
                        // Logo resmi
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Hız Bizde Güven Bizde',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0D47A1), // Koyu mavi
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lütfen bir seçenek seçin',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1565C0).withAlpha(230),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Login Cards
                  Column(
                    children: [
                      Row(
                        children: [
                          // İşletme Giriş Kartı
                          Expanded(
                            child: _buildLoginCard(
                              context,
                              title: 'İşletme Girişi',
                              icon: Icons.business,
                              description: 'İşletmeniz ile giriş yapın',
                              color: Colors.white,
                              textColor: Color(0xFF1976D2),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const IsletmeGirisEkrani(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Kurye Giriş Kartı
                          Expanded(
                            child: _buildLoginCard(
                              context,
                              title: 'Kurye Girişi',
                              icon: Icons.delivery_dining_rounded,
                              description: 'Kurye olarak giriş yapın',
                              color: Colors.white,
                              textColor: Color(0xFF1976D2),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const KuryeGirisEkrani(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Kayıt Ol Butonları
                      Row(
                        children: [
                          Expanded(
                            child: _buildRegisterButton(
                              context,
                              label: 'İşletme Kaydı',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const IsletmeKayitEkrani(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildRegisterButton(
                              context,
                              label: 'Kurye Kaydı',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const KuryeKayitEkrani(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2), // Mavi arka plan
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1976D2).withAlpha(178)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 69, 143, 255).withAlpha(77),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      69,
                      143,
                      255,
                    ).withAlpha(128),
                  ),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 255, 255, 255), // Beyaz yazı
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ), // Beyaz arka plan
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF42A5F5).withAlpha(
                        102,
                      ), // Daha canlı ve açık mavi // Daha canlı gölge
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Giriş Yap',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
