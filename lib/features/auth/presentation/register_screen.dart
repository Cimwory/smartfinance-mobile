import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/presentation/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  int _passwordStrength = 0; // 0: None, 1: Weak, 2: Medium, 3: Strong

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final val = _passwordController.text;
    int strength = 0;
    
    if (val.isNotEmpty) strength = 1;
    if (val.length >= 8 && RegExp(r'[A-Z]').hasMatch(val) && RegExp(r'[0-9]').hasMatch(val)) {
      strength = 2;
    }
    if (val.length >= 10 && RegExp(r'[^A-Za-z0-9]').hasMatch(val) && strength == 2) {
      strength = 3;
    }
    
    if (strength != _passwordStrength) {
      setState(() {
        _passwordStrength = strength;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Backend expects confirm_password. Since it's removed from UI for simplicity, we pass password twice.
      final success = await ref.read(authProvider.notifier).register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
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
            SnackBar(content: Text(error ?? 'Registration failed'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.getFont(
            'JetBrains Mono',
            color: const Color(0xFFbac9cc), // on-surface-variant
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1e2020), // surface-container
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            style: GoogleFonts.hankenGrotesk(color: const Color(0xFFe3e2e2)), // on-surface
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFF849396)), // outline
              prefixIcon: Icon(icon, color: const Color(0xFF849396), size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF849396),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00e5ff), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121414), // background
      body: Stack(
        children: [
          // Background Mesh
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
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
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFc3f5ff).withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  // Top App Bar Alternative
                  Center(
                    child: Text(
                      'NEXIO',
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9cf0ff), // primary-fixed
                        letterSpacing: -0.56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Main Registration Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sora(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFe3e2e2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join the future of wealth management.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 14,
                                  color: const Color(0xFFbac9cc), // on-surface-variant
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Form Inputs
                              _buildInputField(
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                hint: 'Enter your full name',
                                controller: _nameController,
                                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                label: 'Email Address',
                                icon: Icons.mail_outline,
                                hint: 'Enter your email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                hint: 'Create a strong password',
                                controller: _passwordController,
                                isPassword: true,
                                validator: (value) => value == null || value.length < 8 ? 'Min 8 characters required' : null,
                              ),
                              
                              // Password Strength Indicator (Liquid Fill)
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF343535), // surface-variant
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        height: 6,
                                        width: _passwordStrength == 0 
                                            ? 0 
                                            : MediaQuery.of(context).size.width * (_passwordStrength == 1 ? 0.3 : (_passwordStrength == 2 ? 0.6 : 0.9)),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(9999),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFffb4ab),
                                              Color(0xFFFBBC05),
                                              Color(0xFF00e5ff),
                                              Color(0xFF00A3B5),
                                              Color(0xFF00e5ff),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      _passwordStrength == 0 ? '' : (_passwordStrength == 1 ? 'WEAK' : (_passwordStrength == 2 ? 'MEDIUM' : 'SECURE')),
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.getFont(
                                        'JetBrains Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _passwordStrength == 1 
                                            ? const Color(0xFFffb4ab) 
                                            : (_passwordStrength == 2 ? const Color(0xFFFBBC05) : const Color(0xFF00e5ff)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Primary CTA
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
                                  onPressed: authState.isLoading ? null : _register,
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
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: GoogleFonts.sora(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF00363d), // on-primary
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, color: Color(0xFF00363d), size: 20),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Or continue with
                              Row(
                                children: [
                                  const Expanded(child: Divider(color: Color(0xFF3b494c))), // outline-variant
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR CONTINUE WITH',
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
                              const SizedBox(height: 24),

                              // Social Signup
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
                                  'Sign up with Google',
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

                              // Sign in link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc), fontSize: 14),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Sign In',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
