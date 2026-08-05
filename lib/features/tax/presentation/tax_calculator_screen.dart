import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/tax_provider.dart';
import 'tax_detail_screen.dart';

class TaxCalculatorScreen extends ConsumerStatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  ConsumerState<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends ConsumerState<TaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tahunController = TextEditingController(text: DateTime.now().year.toString());
  final _penghasilanBulananController = TextEditingController();
  final _penghasilanTidakTeraturController = TextEditingController(text: '0');
  final _iuranPensiunController = TextEditingController(text: '0');
  final _zakatController = TextEditingController(text: '0');
  final _kreditPajakController = TextEditingController(text: '0');
  
  String _metodePerhitungan = 'tahunan';
  String? _statusWajibPajak;

  @override
  void initState() {
    super.initState();
    // Set default status if available
    final statuses = ref.read(taxProvider).statuses;
    if (statuses.isNotEmpty) {
      _statusWajibPajak = statuses.first;
    }
  }

  @override
  void dispose() {
    _tahunController.dispose();
    _penghasilanBulananController.dispose();
    _penghasilanTidakTeraturController.dispose();
    _iuranPensiunController.dispose();
    _zakatController.dispose();
    _kreditPajakController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_statusWajibPajak == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Status Wajib Pajak')));
      return;
    }

    final data = {
      'tahun_pajak': _tahunController.text,
      'metode_perhitungan': _metodePerhitungan,
      'status_wajib_pajak': _statusWajibPajak,
      'penghasilan_bulanan': _penghasilanBulananController.text.replaceAll('.', ''),
      'penghasilan_tidak_teratur': _penghasilanTidakTeraturController.text.replaceAll('.', ''),
      'iuran_pensiun': _iuranPensiunController.text.replaceAll('.', ''),
      'zakat': _zakatController.text.replaceAll('.', ''),
      'kredit_pajak': _kreditPajakController.text.replaceAll('.', ''),
    };

    final newId = await ref.read(taxProvider.notifier).calculateTax(data);

    if (newId != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kalkulasi pajak berhasil disimpan!')),
      );
      if (newId > 0) {
        try {
          final result = ref.read(taxProvider).history.firstWhere((element) => element.id == newId);
          Navigator.push(context, MaterialPageRoute(builder: (_) => TaxDetailScreen(result: result.hasilJson, id: newId)));
        } catch (e) {
          // If firstWhere fails, we can just wait a bit or show an error
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan, silakan cek riwayat.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxProvider);
    final isLoading = state.isLoading;
    final statuses = state.statuses;
    
    // Ensure selected status is valid when statuses arrive
    if (statuses.isNotEmpty && _statusWajibPajak == null) {
      _statusWajibPajak = statuses.first;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kalkulator Pajak', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Masukkan data penghasilan Anda untuk mendapatkan estimasi PPh 21 yang akurat.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tahunController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tahun Pajak',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _metodePerhitungan,
                    decoration: InputDecoration(
                      labelText: 'Metode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      prefixIcon: const Icon(Icons.calculate_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tahunan', child: Text('PPh 21 Tahunan')),
                      DropdownMenuItem(value: 'ter', child: Text('TER (Bulanan)')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _metodePerhitungan = newValue);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (statuses.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _statusWajibPajak,
                decoration: InputDecoration(
                  labelText: 'Status Wajib Pajak',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  prefixIcon: const Icon(Icons.family_restroom),
                ),
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _statusWajibPajak = newValue);
                },
              )
            else
              const Center(child: CircularProgressIndicator()),
              
            const SizedBox(height: 24),
            const Text(
              'Detail Penghasilan & Pengurang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _penghasilanBulananController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Penghasilan Bruto (Per Bulan)',
                hintText: 'Gaji pokok + tunjangan teratur',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                filled: true,
                fillColor: AppTheme.cardColor,
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (double.tryParse(value.replaceAll('.', '')) == null) return 'Harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _penghasilanTidakTeraturController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Penghasilan Tidak Teratur',
                hintText: 'THR, Bonus, Insentif (Total setahun)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                filled: true,
                fillColor: AppTheme.cardColor,
                prefixIcon: const Icon(Icons.card_giftcard),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _iuranPensiunController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Iuran Pensiun / BPJS (Per Bulan)',
                hintText: 'Ditanggung pegawai',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                filled: true,
                fillColor: AppTheme.cardColor,
                prefixIcon: const Icon(Icons.shield_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _zakatController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Zakat / Sumbangan Keagamaan',
                hintText: 'Total dibayar tahun ini',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                filled: true,
                fillColor: AppTheme.cardColor,
                prefixIcon: const Icon(Icons.favorite_border),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _kreditPajakController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Kredit Pajak (PPh 21 yang sudah dipotong)',
                hintText: 'Opsional',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.cardColor)),
                filled: true,
                fillColor: AppTheme.cardColor,
                prefixIcon: const Icon(Icons.receipt_long),
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Hitung Pajak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
