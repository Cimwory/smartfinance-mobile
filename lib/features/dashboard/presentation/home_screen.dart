import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../smart_finance/presentation/smart_finance_history_screen.dart';
import '../../financial_targets/presentation/financial_targets_screen.dart';
import '../../tax/presentation/tax_history_screen.dart';
import '../../stata/presentation/stata_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _blobController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _blobAnimation;

  @override
  void initState() {
    super.initState();
    
    // Entrance animations (slide up + fade in)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Ambient blob animations
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    
    _blobAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOutSine),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final name = user?['name'] ?? 'Pengguna';

    return Scaffold(
      backgroundColor: const Color(0xFF121414), // surface / background
      body: Stack(
        children: [
          // Animated Background Blobs (Circuit-bg simulation & radial gradients)
          AnimatedBuilder(
            animation: _blobAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100,
                    left: -100,
                    child: Transform.scale(
                      scale: _blobAnimation.value,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00e5ff).withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    right: -100,
                    child: Transform.scale(
                      scale: 2.0 - _blobAnimation.value,
                      child: Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9cf0ff).withOpacity(0.05),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Top AppBar Custom
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout, color: Color(0xFFbac9cc)),
                            onPressed: () => _handleLogout(context, ref),
                          ),
                          Text(
                            'NEXIO',
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9cf0ff), // primary-fixed
                              letterSpacing: -0.56,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.account_circle, color: Color(0xFFbac9cc)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03), // glass-panel
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Stack(
                                children: [
                                  // Subtle gradient corner
                                  Positioned(
                                    top: -20,
                                    left: -20,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF00e5ff).withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BERANDA UTAMA',
                                            style: GoogleFonts.getFont(
                                              'JetBrains Mono',
                                              color: const Color(0xFFbac9cc), // on-surface-variant
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Halo, $name!',
                                            style: GoogleFonts.sora(
                                              color: const Color(0xFF9cf0ff), // primary-fixed
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Selamat datang di Nexio Mobile. Silakan pilih layanan yang ingin Anda gunakan hari ini.',
                                            style: GoogleFonts.hankenGrotesk(
                                              color: const Color(0xFFbac9cc),
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Action Grid
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85, // Adjust slightly to fit content nicely
                              children: [
                                _buildServiceCard(
                                  context,
                                  title: 'Smart Finance',
                                  subtitle: 'Automated wealth management',
                                  icon: Icons.bar_chart,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SmartFinanceHistoryScreen()),
                                    );
                                  },
                                ),
                                _buildServiceCard(
                                  context,
                                  title: 'Financial Targets',
                                  subtitle: 'Goal-oriented planning',
                                  icon: Icons.track_changes,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const FinancialTargetsScreen()),
                                    );
                                  },
                                ),
                                _buildServiceCard(
                                  context,
                                  title: 'Perpajakan',
                                  subtitle: 'Tax filing & optimization',
                                  icon: Icons.receipt_long,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const TaxHistoryScreen()),
                                    );
                                  },
                                ),
                                _buildServiceCard(
                                  context,
                                  title: 'Stata Analytics',
                                  subtitle: 'Deep market insights',
                                  icon: Icons.analytics,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const StataScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            
                            // Secondary Action (Lihat Profile)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(9999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person, color: Color(0xFFe3e2e2), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Lihat Profile',
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
                            const SizedBox(height: 48), // Padding bottom
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

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03), // glass-panel
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)), // glass border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00e5ff).withOpacity(0.1), // bg-primary-container/10
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00e5ff), size: 24),
              ),
              const Spacer(),
              // Title
              Text(
                title,
                style: GoogleFonts.sora(
                  color: const Color(0xFFe3e2e2),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.hankenGrotesk(
                  color: const Color(0xFFbac9cc),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
