import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen User'),
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
      body: Column(
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1e293b)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
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
    );
  }

  Widget _buildUserCard(UserModel user) {
    final String initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    Color roleColor;
    if (user.role == 'admin') {
      roleColor = Colors.redAccent;
    } else {
      roleColor = AppTheme.secondaryColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: user),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null || user.avatar!.isEmpty
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: user.status == 'Active' ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
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
                    color: AppTheme.textSecondary,
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
    );
  }

  void _showUserActionBottomModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aksi untuk ${user.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
              const Divider(color: Color(0xFF1e293b), height: 1),
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
              const Divider(color: Color(0xFF1e293b), height: 1),
              _buildModalAction(
                icon: Icons.security_outlined,
                title: 'Ubah Role',
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showChangeRoleDialog(user);
                },
              ),
              const Divider(color: Color(0xFF1e293b), height: 1),
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
              const Divider(color: Color(0xFF1e293b), height: 1),
              _buildModalAction(
                icon: Icons.delete_outline,
                title: 'Hapus User',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(user);
                },
              ),
            ],
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
