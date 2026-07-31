class SmartFinanceResult {
  final double income;
  final Map<String, double> expenses;
  final double totalDebt;
  final double saving;
  final double investment;
  final double emergencyFund;
  final double totalExpenses;
  final double expenseRatio;
  final double savingRatio;
  final double debtRatio;
  final double emergencyMonths;
  final double financialHealthScore;
  final String healthStatus;
  final String statusColor;

  SmartFinanceResult({
    required this.income,
    required this.expenses,
    required this.totalDebt,
    required this.saving,
    required this.investment,
    required this.emergencyFund,
    required this.totalExpenses,
    required this.expenseRatio,
    required this.savingRatio,
    required this.debtRatio,
    required this.emergencyMonths,
    required this.financialHealthScore,
    required this.healthStatus,
    required this.statusColor,
  });

  factory SmartFinanceResult.fromJson(Map<String, dynamic> json) {
    Map<String, double> parsedExpenses = {};
    if (json['expenses'] != null) {
      json['expenses'].forEach((key, value) {
        parsedExpenses[key] = (value as num).toDouble();
      });
    }

    return SmartFinanceResult(
      income: (json['income'] ?? 0).toDouble(),
      expenses: parsedExpenses,
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      saving: (json['saving'] ?? 0).toDouble(),
      investment: (json['investment'] ?? 0).toDouble(),
      emergencyFund: (json['emergencyFund'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      expenseRatio: (json['expenseRatio'] ?? 0).toDouble(),
      savingRatio: (json['savingRatio'] ?? 0).toDouble(),
      debtRatio: (json['debtRatio'] ?? 0).toDouble(),
      emergencyMonths: (json['emergencyMonths'] ?? 0).toDouble(),
      financialHealthScore: (json['financialHealthScore'] ?? 0).toDouble(),
      healthStatus: json['healthStatus'] ?? 'Unknown',
      statusColor: json['statusColor'] ?? 'secondary',
    );
  }
}

class SmartFinanceHistory {
  final int id;
  final String periode;
  final double pemasukan;
  final SmartFinanceResult calculated;

  SmartFinanceHistory({
    required this.id,
    required this.periode,
    required this.pemasukan,
    required this.calculated,
  });

  factory SmartFinanceHistory.fromJson(Map<String, dynamic> json) {
    return SmartFinanceHistory(
      id: json['id'],
      periode: json['periode'],
      pemasukan: (json['pemasukan'] ?? 0).toDouble(),
      calculated: SmartFinanceResult.fromJson(json['calculated'] ?? {}),
    );
  }
}
