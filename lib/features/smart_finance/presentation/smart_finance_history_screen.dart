import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/smart_finance_provider.dart';
import 'smart_finance_form_screen.dart';
import 'smart_finance_result_screen.dart';
import 'package:intl/intl.dart';

class SmartFinanceHistoryScreen extends ConsumerStatefulWidget {
  const SmartFinanceHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SmartFinanceHistoryScreen> createState() => _SmartFinanceHistoryScreenState();
}

class _SmartFinanceHistoryScreenState extends ConsumerState<SmartFinanceHistoryScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smartFinanceProvider.notifier).fetchHistory();
    });
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Hapus Riwayat', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat analisis ini?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(smartFinanceProvider.notifier).deleteHistory(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat berhasil dihapus'), backgroundColor: Colors.green),
                );
              } else if (mounted) {
                final error = ref.read(smartFinanceProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? 'Gagal menghapus'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartFinanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmartFinanceFormScreen()),
              );
            },
          )
        ],
      ),
      body: state.isLoading && state.history.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada riwayat analisis',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SmartFinanceFormScreen()),
                          );
                        },
                        child: const Text('Mulai Analisis Baru'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(smartFinanceProvider.notifier).fetchHistory(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final item = state.history[index];
                      Color statusColor;
                      switch (item.calculated.statusColor) {
                        case 'success':
                          statusColor = Colors.green;
                          break;
                        case 'warning':
                          statusColor = Colors.orange;
                          break;
                        case 'danger':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = AppTheme.primaryColor;
                      }

                      return Card(
                        color: AppTheme.cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SmartFinanceResultScreen(result: item.calculated, isHistory: true),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.periode,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pemasukan: ${currencyFormatter.format(item.pemasukan)}',
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: statusColor),
                                        ),
                                        child: Text(
                                          item.calculated.healthStatus,
                                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${item.calculated.financialHealthScore.toInt()}/100',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _showDeleteDialog(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
