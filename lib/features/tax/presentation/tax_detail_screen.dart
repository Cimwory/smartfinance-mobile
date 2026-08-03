import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/tax_model.dart';
import '../providers/tax_provider.dart';

class TaxDetailScreen extends ConsumerWidget {
  final TaxResultModel result;
  final int id;

  const TaxDetailScreen({super.key, required this.result, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Kalkulasi', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref, id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
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
                          result.metode.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tahun ${result.tahunPajak}',
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Estimasi Pajak Tahunan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(result.estimasiPajakTahunan),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Per Bulan', currencyFormat.format(result.estimasiPajakBulanan)),
                      _buildSummaryItem('Kurang Bayar', currencyFormat.format(result.pajakKurangBayar)),
                      _buildSummaryItem('Status PKP', result.statusWajibPajak),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result.catatan,
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Rincian Perhitungan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Penghasilan Bulanan', currencyFormat.format(result.penghasilanBulanan)),
                  const Divider(),
                  _buildDetailRow('Penghasilan Tidak Teratur (THR/Bonus)', currencyFormat.format(result.penghasilanTidakTeratur)),
                  const Divider(),
                  _buildDetailRow('Biaya Jabatan (Bulanan)', currencyFormat.format(result.biayaJabatanBulanan)),
                  const Divider(),
                  _buildDetailRow('Iuran Pensiun / BPJS', currencyFormat.format(result.iuranPensiun)),
                  const Divider(),
                  _buildDetailRow('Zakat', currencyFormat.format(result.zakat)),
                  const Divider(),
                  _buildDetailRow('Kredit Pajak (PPh 21 dibayar)', currencyFormat.format(result.kreditPajak)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Perhitungan Pajak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Total Penghasilan Tahunan', currencyFormat.format(result.penghasilanTahunan)),
                  const Divider(),
                  _buildDetailRow('Total Pengurang Tahunan', currencyFormat.format(result.pengurangTahunan), isDeduction: true),
                  const Divider(),
                  _buildDetailRow('Penghasilan Neto', currencyFormat.format(result.penghasilanNeto), isBold: true),
                  const Divider(),
                  _buildDetailRow('PTKP (${result.statusWajibPajak})', currencyFormat.format(result.ptkp), isDeduction: true),
                  const Divider(),
                  _buildDetailRow('Penghasilan Kena Pajak (PKP)', currencyFormat.format(result.pkp), isBold: true, color: const Color(0xFFF59E0B)),
                ],
              ),
            ),

            if (result.metode == 'tahunan' && result.breakdown.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Lapisan Tarif PPh 21 (Progresif)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.breakdown.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final layer = result.breakdown[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(layer.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  'Tarif: ${(layer.rate * 100).toStringAsFixed(0)}% x ${currencyFormat.format(layer.taxableAmount)}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(layer.tax),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            if (result.metode == 'ter') ...[
              const SizedBox(height: 24),
              const Text(
                'Perhitungan TER (Tarif Efektif Rata-rata)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Kategori TER', 'Kategori ${result.terCategory}', isBold: true),
                    const Divider(),
                    _buildDetailRow('Tarif Efektif', '${result.terRate.toStringAsFixed(2)}%', isBold: true),
                    const Divider(),
                    _buildDetailRow('Pajak Bulanan (Penghasilan x Tarif)', currencyFormat.format(result.estimasiPajakBulanan), isBold: true, color: const Color(0xFF10B981)),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isDeduction = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: isBold ? Colors.white : AppTheme.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              isDeduction ? '- $value' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color ?? (isDeduction ? Colors.red : Colors.white),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat kalkulasi pajak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(taxProvider.notifier).deleteTaxHistory(id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat berhasil dihapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
