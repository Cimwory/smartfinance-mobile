import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_users_provider.dart';
import '../data/models/user_model.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121414), // Cyber background
      appBar: AppBar(
        title: Text(
          'Manajemen User',
          style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Tambah User akan datang')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cyber Ambient Background
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00e5ff).withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.hankenGrotesk(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: GoogleFonts.hankenGrotesk(color: const Color(0xFFbac9cc)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFbac9cc)),
                filled: true,
                fillColor: const Color(0xFF1a1c1c).withOpacity(0.5), // glass-panel
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: Color(0xFF00e5ff), width: 1.5),
                ),
              ),
            ),
          ),
          
          // User List
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, stack) => Center(
                child: Text(
                  'Error: ${err.toString()}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (users) {
                final filteredUsers = users.where((user) {
                  final name = user.name.toLowerCase();
                  final email = user.email.toLowerCase();
                  final search = _searchQuery.toLowerCase();
                  return name.contains(search) || email.contains(search);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada user ditemukan.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final String initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    Color roleColor;
    if (user.role == 'admin') {
      roleColor = const Color(0xFF9cf0ff); // primary-fixed
    } else {
      roleColor = const Color(0xFFbac9cc); // on-surface-variant
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), // glass-panel
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailScreen(user: user),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00e5ff).withOpacity(0.1),
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null || user.avatar!.isEmpty
                      ? Text(
                          initial,
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00e5ff),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.status == 'Active' 
                                  ? const Color(0xFF388E3C).withOpacity(0.2) 
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.status,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user.status == 'Active' ? const Color(0xFF81C784) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.hankenGrotesk(
                          color: const Color(0xFFbac9cc),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: roleColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: GoogleFonts.getFont(
                            'JetBrains Mono',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Icon
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFFbac9cc),
                  ),
                  onPressed: () {
                    _showUserActionBottomModal(user);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  void _showUserActionBottomModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1c1c), // glass-panel low
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Aksi untuk ${user.name}',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildModalAction(
                  icon: Icons.person_outline,
                  title: 'Lihat Detail User',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFF2a2c2c), height: 1),
                _buildModalAction(
                  icon: Icons.edit_outlined,
                  title: 'Edit User',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Edit User belum tersedia')),
                    );
                  },
                ),
                const Divider(color: Color(0xFF2a2c2c), height: 1),
                _buildModalAction(
                  icon: Icons.security_outlined,
                  title: 'Ubah Role',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    _showChangeRoleDialog(user);
                  },
                ),
                const Divider(color: Color(0xFF2a2c2c), height: 1),
                _buildModalAction(
                  icon: user.status == 'Active' ? Icons.block_outlined : Icons.check_circle_outline,
                  title: user.status == 'Active' ? 'Nonaktifkan User' : 'Aktifkan User',
                  color: Colors.orangeAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await ref.read(adminUsersProvider.notifier).toggleStatus(user.id);
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Status user ${user.name} berhasil diubah')),
                      );
                    }
                  },
                ),
                const Divider(color: Color(0xFF2a2c2c), height: 1),
                _buildModalAction(
                  icon: Icons.delete_outline,
                  title: 'Hapus User',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog(user);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showChangeRoleDialog(UserModel user) {
    String selectedRole = user.role;
    final roles = ['admin', 'user'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              title: const Text('Ubah Role User', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: roles.map((role) {
                  return RadioListTile<String>(
                    title: Text(
                      role.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: role,
                    groupValue: selectedRole,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    if (selectedRole != user.role) {
                      final success = await ref.read(adminUsersProvider.notifier).updateRole(user.id, selectedRole);
                      if (mounted && success) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Role berhasil diubah menjadi ${selectedRole.toUpperCase()}')),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Gagal mengubah role. Mungkin Anda tidak bisa mengubah role Anda sendiri.')),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text('Apakah Anda yakin ingin menghapus user ${user.name}?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
              if (mounted && success) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('User ${user.name} berhasil dihapus')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus user.')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
