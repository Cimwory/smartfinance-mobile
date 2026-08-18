import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_circuit_logo.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_email_screen.dart';
import 'register_screen.dart';
import '../../dashboard/presentation/admin_dashboard.dart';
import '../../dashboard/presentation/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );

      if (success) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          final error = ref.read(authProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Login failed'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0d0e0f), // surface-container-lowest
      body: Stack(
        children: [
          // Subtle animated background elements / mesh-bg
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00e5ff).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFc3c6d7).withOpacity(0.05), // secondary-fixed-dim
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Header
                    const SizedBox(
                      width: 96,
                      height: 96,
                      child: AnimatedCircuitLogo(size: 96),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NEXIO',
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFe3e2e2), // on-surface
                        letterSpacing: -0.56,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Card (glass-panel)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1c1c).withOpacity(0.4), // surface-container-low/40
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign in',
                                  style: GoogleFonts.sora(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFe3e2e2),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Email Input
                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.hankenGrotesk(color: const Color(0xFFe3e2e2), fontSize: 16),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Your Email',
                                    labelStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc)), // on-surface-variant
                                    floatingLabelStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFF00e5ff)),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF3b494c)), // outline-variant
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF00e5ff), width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.only(bottom: 8),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                                ),
                                const SizedBox(height: 24),
                                
                                // Password Input
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.hankenGrotesk(color: const Color(0xFFe3e2e2), fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc)),
                                    floatingLabelStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFF00e5ff)),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF3b494c)),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF00e5ff), width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.only(bottom: 8),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFFbac9cc),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                                ),
                                
                                // Forgot Password
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const ForgotPasswordEmailScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.sora(
                                        color: const Color(0xFF9cf0ff), // primary-fixed
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Sign in Button
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9999),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00E5FF), Color(0xFF00A3B5)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: authState.isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            'Sign in',
                                            style: GoogleFonts.sora(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // OR Divider
                                Row(
                                  children: [
                                    const Expanded(child: Divider(color: Color(0xFF3b494c))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: GoogleFonts.getFont(
                                          'JetBrains Mono',
                                          color: const Color(0xFFbac9cc),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Color(0xFF3b494c))),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Google Sign in
                                OutlinedButton.icon(
                                  onPressed: authState.isLoading ? null : () async {
                                    final success = await ref.read(authProvider.notifier).loginWithGoogle();
                                    if (success) {
                                      if (mounted) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                                          (route) => false,
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        final error = ref.read(authProvider).error;
                                        if (error != null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(error), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  icon: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    height: 20,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.white),
                                  ),
                                  label: Text(
                                    'Sign in with Google',
                                    style: GoogleFonts.sora(
                                      color: const Color(0xFFe3e2e2),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFF292a2a).withOpacity(0.5),
                                    side: const BorderSide(color: Color(0xFF3b494c)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Not a Member? ',
                                      style: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc), fontSize: 14),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                        );
                                      },
                                      child: Text(
                                        'Sign up here',
                                        style: GoogleFonts.hankenGrotesk(
                                          color: const Color(0xFF9cf0ff),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Development Shortcuts (Preserved for easy testing)
                    const Divider(color: Color(0xFF3b494c)),
                    const SizedBox(height: 8),
                    Text(
                      'Development Shortcuts:',
                      style: GoogleFonts.getFont('JetBrains Mono', color: const Color(0xFFbac9cc), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 8.0,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.person, size: 16, color: Colors.greenAccent),
                          label: Text('Go to User', style: GoogleFonts.sora(color: Colors.greenAccent, fontSize: 12)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final TextEditingController pinController = TextEditingController();
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF1a1c1c),
                                  title: Text('Admin Access', style: GoogleFonts.sora(color: Colors.white)),
                                  content: TextField(
                                    controller: pinController,
                                    obscureText: true,
                                    style: GoogleFonts.hankenGrotesk(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Enter Admin PIN',
                                      labelStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc)),
                                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3b494c))),
                                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00e5ff))),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text('Cancel', style: GoogleFonts.sora(color: const Color(0xFFbac9cc))),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (pinController.text == 'admin123') {
                                          Navigator.pop(ctx);
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(builder: (_) => const AdminDashboard()),
                                            (route) => false,
                                          );
                                        } else {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Invalid PIN'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('OK', style: GoogleFonts.sora(color: const Color(0xFF00e5ff))),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.blueAccent),
                          label: Text('Go to Admin', style: GoogleFonts.sora(color: Colors.blueAccent, fontSize: 12)),
                        ),
                      ],
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
