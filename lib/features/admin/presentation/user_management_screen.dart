import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  // Dummy data for UI showcase
  final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'role': 'admin',
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'role': 'user',
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 3,
      'name': 'Robert Johnson',
      'email': 'robert.j@example.com',
      'role': 'user',
      'status': 'Inactive',
      'avatar': null,
    },
    {
      'id': 4,
      'name': 'Emily Davis',
      'email': 'emily.davis@example.com',
      'role': 'user',
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 5,
      'name': 'Michael Wilson',
      'email': 'm.wilson@example.com',
      'role': 'user',
      'status': 'Active',
      'avatar': null,
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _dummyUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      final search = _searchQuery.toLowerCase();
      return name.contains(search) || email.contains(search);
    }).toList();

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
              // TODO: Implement Add User action
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
                  borderSide: BorderSide(color: const Color(0xFF1e293b)),
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
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada user ditemukan.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String name = user['name'];
    final String email = user['email'];
    final String role = user['role'];
    final String status = user['status'];
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Color roleColor;
    if (role == 'admin') {
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
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: user),
              ),
            );
            if (result == true) {
              setState(() {
                _dummyUsers.removeWhere((u) => u['id'] == user['id']);
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
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
                              name,
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
                              color: status == 'Active' 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: status == 'Active' ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
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
                          role.toUpperCase(),
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

  void _showUserActionBottomModal(Map<String, dynamic> user) {
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
                'Aksi untuk ${user['name']}',
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
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(user: user),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _dummyUsers.removeWhere((u) => u['id'] == user['id']);
                    });
                  }
                },
              ),
              const Divider(color: Color(0xFF1e293b), height: 1),
              _buildModalAction(
                icon: Icons.edit_outlined,
                title: 'Edit User',
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit user implementation
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
                icon: Icons.block_outlined,
                title: user['status'] == 'Active' ? 'Nonaktifkan User' : 'Aktifkan User',
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Toggle status implementation
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

  void _showChangeRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'];
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
                  onPressed: () {
                    // Update the state
                    setState(() {
                      final index = _dummyUsers.indexWhere((u) => u['id'] == user['id']);
                      if (index != -1) {
                        _dummyUsers[index]['role'] = selectedRole;
                      }
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Role berhasil diubah menjadi ${selectedRole.toUpperCase()}')),
                    );
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

  void _showDeleteConfirmationDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text('Apakah Anda yakin ingin menghapus user ${user['name']}?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dummyUsers.removeWhere((u) => u['id'] == user['id']);
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('User ${user['name']} berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

