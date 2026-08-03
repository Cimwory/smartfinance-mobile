import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/stata_provider.dart';

class StataScreen extends ConsumerStatefulWidget {
  const StataScreen({super.key});

  @override
  ConsumerState<StataScreen> createState() => _StataScreenState();
}

class _StataScreenState extends ConsumerState<StataScreen> {
  final _commandController = TextEditingController();
  final ScrollController _outputScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(stataProvider.notifier).fetchState());
  }

  @override
  void dispose() {
    _commandController.dispose();
    _outputScrollController.dispose();
    super.dispose();
  }

  void _runCommand() async {
    if (_commandController.text.trim().isEmpty) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    final success = await ref.read(stataProvider.notifier).runCommand(_commandController.text);
    if (success) {
      _commandController.clear();
      // Scroll to bottom after a short delay to let the UI update
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_outputScrollController.hasClients) {
          _outputScrollController.animateTo(
            _outputScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(stataProvider).error ?? 'Gagal menjalankan perintah')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stataProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Stata Analytics', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (state.dataset != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Tutup Dataset',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: state.isLoading && state.dataset == null
          ? const Center(child: CircularProgressIndicator())
          : state.dataset == null
              ? _buildEmptyState()
              : _buildWorkspace(state),
    );
  }

  Widget _buildEmptyState() {
    final isLoading = ref.watch(stataProvider).isLoading;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text(
              'Belum ada Dataset',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unggah file dataset Stata (.dta) untuk memulai analisis statistik.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => ref.read(stataProvider.notifier).importDataset(),
              icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.upload_file),
              label: Text(isLoading ? 'Mengunggah...' : 'Pilih File .dta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace(StataState state) {
    return Column(
      children: [
        // Dataset Info Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.dataset, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.dataset!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          '${(state.dataset!.size / 1024).toStringAsFixed(2)} KB',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                state.dataset!.summary,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.dataset!.variables.map((v) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(v, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        
        // Output Console
        Expanded(
          child: Container(
            color: const Color(0xFF0F172A), // Dark console background
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: state.isLoading && state.output == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : state.output == null
                    ? const Center(
                        child: Text(
                          'Ketik perintah Stata (misal: summarize, describe) di bawah.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _outputScrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '> ${state.output!.command}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (state.output!.text != null)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  state.output!.text!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ),

        // Command Input Layer
        Container(
          color: AppTheme.cardColor,
          padding: EdgeInsets.only(
            left: 16, 
            right: 16, 
            top: 16, 
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commandController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Stata command (e.g. summarize price)',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: (_) => _runCommand(),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: state.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: state.isLoading ? null : _runCommand,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Dataset'),
        content: const Text('Anda yakin ingin menutup dataset ini? Semua output yang belum tersimpan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(stataProvider.notifier).clearDataset();
            },
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
