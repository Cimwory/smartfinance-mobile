import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/animated_circuit_logo.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121414), // bg-background
      body: Stack(
        children: [
          // 1. Efek Mesh Gradient (Blobs) dari HTML (lebih subtle)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00daf3), // primary-fixed-dim
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00e5ff), // primary-container
              ),
            ),
          ),
          // Blur layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: const Color(0xFF121414).withOpacity(0.9), // Lebih gelap agar neon pop up
              ),
            ),
          ),

          // 2. Konten Utama
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo N Animasi SVG ke CustomPainter
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: const SizedBox(
                          width: 128,
                          height: 128,
                          child: Center(
                            child: AnimatedCircuitLogo(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Judul (Headline) menggunakan font Sora
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Nexio Mobile',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9cf0ff), // primary-fixed
                            letterSpacing: -0.84,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subjudul menggunakan font Hanken Grotesk
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            'Solusi cerdas untuk mengelola dan merencanakan masa depan keuangan Anda.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 16,
                              color: const Color(0xFFbac9cc), // on-surface-variant
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Tombol Aksi
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tombol Masuk (Gradasi Cyan + Glow)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00e5ff), Color(0xFF00daf3)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00e5ff).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: Text(
                                  'Masuk ke Akun',
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00363d), // on-primary
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Tombol Daftar (Glassmorphism Dark)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(color: Colors.white.withOpacity(0.10)), // Lebih subtle
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9999),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: Text(
                                      'Daftar Akun Baru',
                                      style: GoogleFonts.sora(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFe3e2e2), // on-surface
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
