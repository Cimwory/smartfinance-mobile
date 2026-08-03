import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/smart_finance_model.dart';
import '../providers/smart_finance_pdf_service.dart';

class SmartFinanceResultScreen extends StatelessWidget {
  final SmartFinanceResult result;
  final bool isHistory;
  final String? periode;

  const SmartFinanceResultScreen({
    Key? key,
    required this.result,
    this.isHistory = false,
    this.periode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    Color statusColor;
    switch (result.statusColor) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        leading: isHistory
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF',
            onPressed: () async {
              final actualPeriode = periode ?? DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
              await SmartFinancePdfService.generateAndSharePdf(result, actualPeriode);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text('Skor Kesehatan Finansial', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    '${result.financialHealthScore.toInt()}',
                    style: TextStyle(color: statusColor, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.healthStatus.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Chart
            const Text(
              'Alokasi Pengeluaran',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildPieChart(),
            ),
            
            const SizedBox(height: 24),
            // Metrics
            _buildMetricCard('Pemasukan', currencyFormatter.format(result.income), Icons.account_balance_wallet, Colors.green),
            _buildMetricCard('Total Pengeluaran', currencyFormatter.format(result.totalExpenses), Icons.money_off, Colors.red),
            _buildMetricCard('Tabungan & Investasi', currencyFormatter.format(result.saving + result.investment), Icons.savings, Colors.blue),
            _buildMetricCard('Dana Darurat', currencyFormatter.format(result.emergencyFund), Icons.health_and_safety, Colors.purple),
            
            const SizedBox(height: 24),
            // Ratios
            const Text(
              'Rasio Keuangan',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRatioBar('Rasio Pengeluaran', result.expenseRatio, 50, Colors.red),
            _buildRatioBar('Rasio Tabungan', result.savingRatio, 20, Colors.blue, higherIsBetter: true),
            _buildRatioBar('Rasio Utang', result.debtRatio, 30, Colors.orange),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    List<PieChartSectionData> sections = [];
    int i = 0;
    final colors = [Colors.blue, Colors.red, Colors.orange, Colors.purple, Colors.teal, Colors.pink];
    
    result.expenses.forEach((key, value) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: value,
            title: '${(value / result.totalExpenses * 100).toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
        i++;
      }
    });

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildLegends(colors),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLegends(List<Color> colors) {
    List<Widget> legends = [];
    int i = 0;
    result.expenses.forEach((key, value) {
      if (value > 0) {
        legends.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 12, height: 12, color: colors[i % colors.length]),
                const SizedBox(width: 8),
                Expanded(child: Text(key, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
        i++;
      }
    });
    return legends;
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRatioBar(String title, double value, double idealTarget, Color color, {bool higherIsBetter = false}) {
    bool isGood = higherIsBetter ? value >= idealTarget : value <= idealTarget;
    Color barColor = isGood ? Colors.green : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
              Text('${value.toStringAsFixed(1)}%', style: TextStyle(color: barColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: AppTheme.cardColor,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            'Target Ideal: ${higherIsBetter ? '>=' : '<='} $idealTarget%',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
