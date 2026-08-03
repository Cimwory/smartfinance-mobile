import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/financial_target_provider.dart';
import 'create_edit_target_screen.dart';
import 'widgets/add_deposit_dialog.dart';

class TargetDetailScreen extends ConsumerStatefulWidget {
  final int targetId;

  const TargetDetailScreen({super.key, required this.targetId});

  @override
  ConsumerState<TargetDetailScreen> createState() => _TargetDetailScreenState();
}

class _TargetDetailScreenState extends ConsumerState<TargetDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(financialTargetProvider.notifier).fetchTargetDetails(widget.targetId));
  }

  void _showAddDepositDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddDepositDialog(targetId: widget.targetId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financialTargetProvider);
    final target = state.currentTarget;
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (state.isLoading && target == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (target == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black),
        body: const Center(child: Text('Target not found')),
      );
    }

    Color getStatusColor() {
      if (target.status == 'completed') return Colors.green;
      if (target.isOverdue) return Colors.red;
      return const Color(0xFF3B82F6);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Target Detail', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEditTargetScreen(target: target),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, widget.targetId),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(financialTargetProvider.notifier).fetchTargetDetails(widget.targetId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            target.category.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            target.status.toUpperCase(),
                            style: TextStyle(color: getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      target.name,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (target.description != null && target.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        target.description!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text('Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(target.currentAmount),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4, left: 4, right: 4),
                          child: Text('/', style: TextStyle(color: Colors.white70)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            currencyFormat.format(target.targetAmount),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (target.progress / 100).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${target.progress.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('${target.daysRemaining} days left', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recommended Action
              if (target.status == 'active' && target.recommendedMonthly > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommendation',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Save ${currencyFormat.format(target.recommendedMonthly)} per month to reach your goal on time.',
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deposit History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (target.status == 'active')
                    TextButton.icon(
                      onPressed: _showAddDepositDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Deposit'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (state.deposits.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('No deposits yet.', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.deposits.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final deposit = state.deposits[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      tileColor: AppTheme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: index == 0
                            ? const BorderRadius.vertical(top: Radius.circular(16))
                            : index == state.deposits.length - 1
                                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                : BorderRadius.zero,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_downward, color: AppTheme.primaryColor, size: 20),
                      ),
                      title: Text(
                        currencyFormat.format(deposit.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(deposit.date, style: const TextStyle(color: AppTheme.textSecondary)),
                          if (deposit.note != null && deposit.note!.isNotEmpty)
                            Text(deposit.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteDeposit(context, deposit.id, target.id),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int targetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Target'),
        content: const Text('Are you sure you want to delete this financial target? All deposit history will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(financialTargetProvider.notifier).deleteTarget(targetId);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target deleted successfully')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDeposit(BuildContext context, int depositId, int targetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deposit'),
        content: const Text('Are you sure you want to remove this deposit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(financialTargetProvider.notifier).removeDeposit(depositId, targetId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
