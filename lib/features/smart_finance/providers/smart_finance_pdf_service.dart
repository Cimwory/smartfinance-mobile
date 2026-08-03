import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../data/models/smart_finance_model.dart';

class SmartFinancePdfService {
  static Future<void> generateAndSharePdf(SmartFinanceResult result, String periode) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    PdfColor statusColor;
    switch (result.statusColor) {
      case 'success':
        statusColor = PdfColors.green700;
        break;
      case 'warning':
        statusColor = PdfColors.orange700;
        break;
      case 'danger':
        statusColor = PdfColors.red700;
        break;
      default:
        statusColor = PdfColors.blue700;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(periode),
            pw.SizedBox(height: 24),
            _buildScoreCard(result, statusColor),
            pw.SizedBox(height: 24),
            _buildSummary(result, currencyFormatter),
            pw.SizedBox(height: 24),
            _buildExpensesBreakdown(result, currencyFormatter),
            pw.SizedBox(height: 24),
            _buildRatios(result),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10.0),
            child: pw.Text(
              'Nexio Mobile - Smart Finance',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_Keuangan_Nexio_$periode.pdf',
    );
  }

  static pw.Widget _buildHeader(String periode) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Laporan Analisis Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 8),
        pw.Text('Periode: $periode', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.Divider(color: PdfColors.grey300),
      ],
    );
  }

  static pw.Widget _buildScoreCard(SmartFinanceResult result, PdfColor statusColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: statusColor, width: 2),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Skor Kesehatan Finansial', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 8),
              pw.Text(
                result.healthStatus.toUpperCase(),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: statusColor),
              ),
            ],
          ),
          pw.Text(
            '${result.financialHealthScore.toInt()}/100',
            style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: statusColor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(SmartFinanceResult result, NumberFormat formatter) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Ringkasan Keuangan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox('Pemasukan', formatter.format(result.income), PdfColors.green700),
            _buildInfoBox('Total Pengeluaran', formatter.format(result.totalExpenses), PdfColors.red700),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox('Tabungan & Investasi', formatter.format(result.saving + result.investment), PdfColors.blue700),
            _buildInfoBox('Dana Darurat', formatter.format(result.emergencyFund), PdfColors.purple700),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoBox(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildExpensesBreakdown(SmartFinanceResult result, NumberFormat formatter) {
    List<pw.Widget> expenseItems = [];
    result.expenses.forEach((key, value) {
      if (value > 0) {
        expenseItems.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(key, style: const pw.TextStyle(fontSize: 12)),
                pw.Text(formatter.format(value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    });

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Rincian Pengeluaran', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          ...expenseItems,
        ],
      ),
    );
  }

  static pw.Widget _buildRatios(SmartFinanceResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rasio Keuangan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        _buildRatioItem('Rasio Pengeluaran', result.expenseRatio, 50, false),
        _buildRatioItem('Rasio Tabungan', result.savingRatio, 20, true),
        _buildRatioItem('Rasio Utang', result.debtRatio, 30, false),
      ],
    );
  }

  static pw.Widget _buildRatioItem(String title, double value, double target, bool higherIsBetter) {
    bool isGood = higherIsBetter ? value >= target : value <= target;
    PdfColor color = isGood ? PdfColors.green700 : PdfColors.orange700;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Target: ${higherIsBetter ? '>=' : '<='} $target%', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
          pw.Text('${value.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
