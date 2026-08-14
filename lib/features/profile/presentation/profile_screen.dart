import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'edit_profile_dialog.dart';
import 'change_email_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1c1c),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?', style: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: GoogleFonts.sora(color: const Color(0xFFbac9cc), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Keluar', style: GoogleFonts.sora(color: const Color(0xFFffb4ab), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final String name = user?['name'] ?? 'Unknown User';
    final String email = user?['email'] ?? 'No email provided';
    final String role = user?['role'] ?? 'user';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFF121414), // bg-mesh
      body: Stack(
        children: [
          // Ambient Background Blobs
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00e5ff).withOpacity(0.05),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: Transform.scale(
                      scale: 2.0 - _pulseAnimation.value,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFc3f5ff).withOpacity(0.04),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOutCubic,
                )),
                child: Column(
                  children: [
                    // Top App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFFe3e2e2)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Text(
                            'Profil Saya',
                            style: GoogleFonts.sora(
                              color: const Color(0xFFe3e2e2),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF00daf3)), // surface-tint
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => EditProfileDialog(currentUsername: user?['username'] ?? ''),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Avatar Section
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF343535), // surface-container-highest
                                    border: Border.all(color: const Color(0xFF00e5ff).withOpacity(0.8), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00e5ff).withOpacity(0.15),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.sora(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00e5ff), // primary-container
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF00e5ff).withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00e5ff), // primary-container
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF121414), width: 2), // border-surface
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    size: 16,
                                    color: Color(0xFF00363d), // on-primary
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: GoogleFonts.sora(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFe3e2e2),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00e5ff).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: const Color(0xFF00e5ff).withOpacity(0.2)),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: GoogleFonts.getFont(
                                  'JetBrains Mono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF00daf3), // surface-tint
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Account Details
                            _buildInfoCard(
                              icon: Icons.mail_outline,
                              title: 'Email',
                              value: email,
                              actionWidget: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
                                  );
                                },
                                child: Text(
                                  'Ubah',
                                  style: GoogleFonts.sora(
                                    color: const Color(0xFF00daf3), // surface-tint
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              icon: Icons.person_outline,
                              title: 'Username',
                              value: user?['username'] ?? '-',
                            ),
                            
                            const SizedBox(height: 48),

                            // Action Buttons
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gunakan fitur Lupa Password di halaman Login untuk mereset sandi.')),
                                );
                              },
                              borderRadius: BorderRadius.circular(9999),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1a1c1c).withOpacity(0.3), // surface-container-low/30
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: const Color(0xFFbac9cc).withOpacity(0.3)), // on-surface-variant/30
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_outline, color: Color(0xFFe3e2e2), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ubah Password',
                                      style: GoogleFonts.sora(
                                        color: const Color(0xFFe3e2e2),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _handleLogout,
                              borderRadius: BorderRadius.circular(9999),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF93000a).withOpacity(0.1), // error-container/10
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: const Color(0xFFffb4ab).withOpacity(0.3)), // error/30
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.logout, color: Color(0xFFffb4ab), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Keluar',
                                      style: GoogleFonts.sora(
                                        color: const Color(0xFFffb4ab),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Widget? actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1c1c).withOpacity(0.4), // surface-container-low/40
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)), // glass-border
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1e2020).withOpacity(0.8), // surface-container/80
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: const Color(0xFFbac9cc), size: 24), // on-surface-variant
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.getFont(
                    'JetBrains Mono',
                    color: const Color(0xFFbac9cc), // on-surface-variant
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.sora(
                    color: const Color(0xFFe3e2e2), // on-surface
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (actionWidget != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: actionWidget,
            ),
        ],
      ),
    );
  }
}
