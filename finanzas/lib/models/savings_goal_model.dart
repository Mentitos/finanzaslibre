enum GoalStatus { active, completed, cancelled }

class SavingsGoal {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? deadline;
  final String emoji;
  final GoalStatus status;
  final String? imagePath; // Ruta de la imagen local

  SavingsGoal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
    this.deadline,
    this.emoji = '🎯',
    this.status = GoalStatus.active,
    this.imagePath,
  });

  // Progreso en porcentaje (0.0 a 1.0)
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  // Progreso en porcentaje (0 a 100)
  int get progressPercentage => (progress * 100).round();

  // Cuánto falta para completar
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  // Está completada?
  bool get isCompleted => currentAmount >= targetAmount;

  // Días restantes hasta deadline (puede ser negativo si ya pasó)
  int? get daysRemaining {
    if (deadline == null) return null;
    final now = DateTime.now();
    final difference = deadline!.difference(now);
    return difference.inDays;
  }

  // Está vencida?
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  // Cuánto necesitas ahorrar por día para llegar a la meta
  double? get dailySavingsNeeded {
    if (deadline == null || isCompleted) return null;
    final days = daysRemaining;
    if (days == null || days <= 0) return null;
    return remainingAmount / days;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'emoji': emoji,
      'status': status.index,
      'imagePath': imagePath,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      emoji: json['emoji'] as String? ?? '🎯',
      status: GoalStatus.values[json['status'] as int? ?? 0],
      imagePath:
          json['imagePath'] as String? ??
          json['imageUrl'] as String?, // Retrocompatibilidad
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? deadline,
    String? emoji,
    GoalStatus? status,
    String? imagePath,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() => 'SavingsGoal($name: \$$currentAmount/\$$targetAmount)';
}
