import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/smart_finance_provider.dart';
import 'smart_finance_result_screen.dart';

class SmartFinanceFormScreen extends ConsumerStatefulWidget {
  const SmartFinanceFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SmartFinanceFormScreen> createState() => _SmartFinanceFormScreenState();
}

class _SmartFinanceFormScreenState extends ConsumerState<SmartFinanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _periodeController = TextEditingController();
  final _pemasukanController = TextEditingController();
  final _tabunganController = TextEditingController();
  final _targetTabunganController = TextEditingController();
  final _investasiController = TextEditingController();
  final _danaDaruratController = TextEditingController();
  
  List<Map<String, dynamic>> _expenses = [
    {'name': TextEditingController(text: 'Kebutuhan pokok'), 'amount': TextEditingController(), 'is_debt': false},
    {'name': TextEditingController(text: 'Transportasi'), 'amount': TextEditingController(), 'is_debt': false},
    {'name': TextEditingController(text: 'Cicilan/utang'), 'amount': TextEditingController(), 'is_debt': true},
    {'name': TextEditingController(text: 'Gaya hidup'), 'amount': TextEditingController(), 'is_debt': false},
  ];

  @override
  void initState() {
    super.initState();
    // Default periode e.g., "Agustus 2026"
    final now = DateTime.now();
    _periodeController.text = DateFormat('MMMM yyyy', 'id_ID').format(now);
  }

  void _addExpense() {
    setState(() {
      _expenses.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
        'is_debt': false,
      });
    });
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses[index]['name'].dispose();
      _expenses[index]['amount'].dispose();
      _expenses.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> formattedExpenses = _expenses.map((e) {
        return {
          'name': e['name'].text,
          'amount': e['amount'].text.replaceAll(RegExp(r'[^0-9]'), ''),
          'is_debt': e['is_debt'] ? '1' : '0',
        };
      }).toList();

      final data = {
        'periode': _periodeController.text,
        'pemasukan': _pemasukanController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'tabungan': _tabunganController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'target_tabungan': _targetTabunganController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'investasi': _investasiController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'dana_darurat': _danaDaruratController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'expenses': formattedExpenses,
      };

      final success = await ref.read(smartFinanceProvider.notifier).analyze(data);
      if (success && mounted) {
        final result = ref.read(smartFinanceProvider).lastResult;
        if (result != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SmartFinanceResultScreen(result: result, isHistory: false)),
          );
        }
      } else if (mounted) {
        final error = ref.read(smartFinanceProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Gagal menganalisis'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(smartFinanceProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Keuangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Dasar'),
              _buildTextField(_periodeController, 'Periode (Misal: Agustus 2026)', TextInputType.text),
              const SizedBox(height: 16),
              _buildTextField(_pemasukanController, 'Total Pemasukan', TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 16),
              _buildTextField(_tabunganController, 'Tabungan Bulan Ini', TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 16),
              _buildTextField(_targetTabunganController, 'Target Tabungan', TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 16),
              _buildTextField(_investasiController, 'Investasi Bulan Ini', TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 16),
              _buildTextField(_danaDaruratController, 'Total Dana Darurat Saat Ini', TextInputType.number, prefix: 'Rp '),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Pengeluaran'),
                  TextButton.icon(
                    onPressed: _addExpense,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              ..._expenses.asMap().entries.map((entry) {
                int idx = entry.key;
                var expense = entry.value;
                return Card(
                  color: AppTheme.cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: expense['name'],
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Nama Pengeluaran',
                                  isDense: true,
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            if (_expenses.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _removeExpense(idx),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: expense['amount'],
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                inputFormatters: [CurrencyInputFormatter()],
                                decoration: const InputDecoration(
                                  labelText: 'Nominal',
                                  prefixText: 'Rp ',
                                  isDense: true,
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: expense['is_debt'],
                                  onChanged: (val) {
                                    setState(() {
                                      expense['is_debt'] = val;
                                    });
                                  },
                                ),
                                const Text('Cicilan/Utang', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Analisis Sekarang'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, {String? prefix}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: type,
      inputFormatters: type == TextInputType.number ? [CurrencyInputFormatter()] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: AppTheme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
    );
  }
}
