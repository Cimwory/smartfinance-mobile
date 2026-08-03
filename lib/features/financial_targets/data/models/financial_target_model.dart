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
      amount: (json['amount'] ?? 0).toDouble(),
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
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0).toDouble(),
      targetDate: json['target_date'] ?? '',
      status: json['status'] ?? 'active',
      priority: json['priority'],
      progress: (json['progress'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      daysRemaining: json['days_remaining'] ?? 0,
      isAchieved: json['is_achieved'] ?? false,
      isOverdue: json['is_overdue'] ?? false,
      performance: json['performance'],
      recommendedMonthly: (json['recommended_monthly'] ?? 0).toDouble(),
    );
  }
}
