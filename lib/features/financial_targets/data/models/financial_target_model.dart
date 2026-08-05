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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      financialTargetId: json['financial_target_id'] is int ? json['financial_target_id'] : int.tryParse(json['financial_target_id']?.toString() ?? '') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date']?.toString() ?? '',
      note: json['note']?.toString(),
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0.0,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0.0,
      targetDate: json['target_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      priority: json['priority'] is int ? json['priority'] : int.tryParse(json['priority']?.toString() ?? ''),
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0,
      remaining: double.tryParse(json['remaining']?.toString() ?? '0') ?? 0.0,
      daysRemaining: int.tryParse(json['days_remaining']?.toString() ?? '0') ?? 0,
      isAchieved: json['is_achieved'] == 1 || json['is_achieved'] == true || json['is_achieved'] == 'true',
      isOverdue: json['is_overdue'] == 1 || json['is_overdue'] == true || json['is_overdue'] == 'true',
      performance: json['performance'] is Map ? json['performance']['status']?.toString() : json['performance']?.toString(),
      recommendedMonthly: double.tryParse(json['recommended_monthly']?.toString() ?? '0') ?? 0.0,
    );
  }
}
