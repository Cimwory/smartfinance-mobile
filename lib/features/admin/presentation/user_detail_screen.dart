import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? 'Unknown User';
    final String email = user['email'] ?? 'No email';
    final String role = user['role'] ?? 'user';
    final String status = user['status'] ?? 'Inactive';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Color roleColor;
    if (role == 'admin') {
      roleColor = Colors.redAccent;
    } else {
      roleColor = AppTheme.secondaryColor;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail User'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar & Basic Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: roleColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Active' 
                              ? Colors.green.withOpacity(0.2) 
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == 'Active' ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Detailed Information List
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.phone_outlined,
              title: 'Nomor HP',
              value: user['phone'] ?? '-', // Assuming we might have a phone number later
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.date_range_outlined,
              title: 'Bergabung Sejak',
              value: '12 Januari 2024', // Dummy date
            ),

            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Edit user implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Edit User belum tersedia')),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Informasi User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Delete user implementation
                  _showDeleteConfirmation(context, name);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus User'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text('Apakah Anda yakin ingin menghapus user $name?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $name berhasil dihapus')),
              );
              Navigator.of(context).pop(true); // Back to list, returning true to indicate deletion
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
