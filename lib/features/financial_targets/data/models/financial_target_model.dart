class FinancialTargetDepositModel {
  final int id;
  final int financialTargetId;
  final double amount;
  final String date;
  final String? note;

  FinancialTargetDepositModel({
    required this.id,
    required this.financialTargetId,
    required this.amount,
    required this.date,
    this.note,
  });

  factory FinancialTargetDepositModel.fromJson(Map<String, dynamic> json) {
    return FinancialTargetDepositModel(
      id: json['id'],
      financialTargetId: json['financial_target_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date'] ?? '',
      note: json['note'],
    );
  }
}

class FinancialTargetModel {
  final int id;
  final String name;
  final String? description;
  final String category;
  final double targetAmount;
  final double currentAmount;
  final String targetDate;
  final String status;
  final int? priority;
  
  // Computed properties from backend
  final double progress;
  final double remaining;
  final int daysRemaining;
  final bool isAchieved;
  final bool isOverdue;
  final String? performance;
  final double recommendedMonthly;

  FinancialTargetModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    this.priority,
    required this.progress,
    required this.remaining,
    required this.daysRemaining,
    required this.isAchieved,
    required this.isOverdue,
    this.performance,
    required this.recommendedMonthly,
  });

  factory FinancialTargetModel.fromJson(Map<String, dynamic> json) {
    return FinancialTargetModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0.0,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0.0,
      targetDate: json['target_date'] ?? '',
      status: json['status'] ?? 'active',
      priority: json['priority'],
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0,
      remaining: double.tryParse(json['remaining']?.toString() ?? '0') ?? 0.0,
      daysRemaining: int.tryParse(json['days_remaining']?.toString() ?? '0') ?? 0,
      isAchieved: json['is_achieved'] == 1 || json['is_achieved'] == true,
      isOverdue: json['is_overdue'] == 1 || json['is_overdue'] == true,
      performance: json['performance'],
      recommendedMonthly: double.tryParse(json['recommended_monthly']?.toString() ?? '0') ?? 0.0,
    );
  }
}
