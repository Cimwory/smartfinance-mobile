import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import '../../auth/providers/auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final String currentUsername;
  
  const EditProfileDialog({Key? key, required this.currentUsername}) : super(key: key);

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _usernameController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    final username = _usernameController.text;
    final success = await ref.read(authProvider.notifier).updateProfile(
      username.isNotEmpty ? username : null,
      _selectedImage,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
        );
      } else {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Dialog(
      backgroundColor: Colors.transparent, // We use Container with BackdropFilter
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.95) * 20).clamp(0.0, 1.0), // scale from 0.95 to 1.0 means opacity 0 to 1
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1e2020).withOpacity(0.8), // surface-container/80
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00e5ff).withOpacity(0.2)), // primary-container/20
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Text(
                      'Edit Profil',
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFe3e2e2), // on-surface
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF343535),
                              border: Border.all(color: const Color(0xFF00e5ff).withOpacity(0.5), width: 2),
                              image: _selectedImage != null
                                  ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _selectedImage == null
                                ? const Icon(Icons.person, size: 40, color: Color(0xFFbac9cc))
                                : null,
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00e5ff),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF121414), width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF00363d)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: GoogleFonts.sora(
                          color: const Color(0xFFe3e2e2),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a1c1c).withOpacity(0.4), // bg-surface-container-low/40
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: const Color(0xFFbac9cc).withOpacity(0.3)), // border-on-surface-variant/30
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: GoogleFonts.hankenGrotesk(color: const Color(0xFFe3e2e2), fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            hintText: 'Enter username',
                            hintStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFF849396)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.sora(
                            color: const Color(0xFFbac9cc),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00e5ff).withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00e5ff),
                            foregroundColor: const Color(0xFF00363d),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            elevation: 0,
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Color(0xFF00363d), strokeWidth: 2),
                                )
                              : Text(
                                  'Simpan',
                                  style: GoogleFonts.sora(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
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
    );
  }
}
