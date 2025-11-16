enum RecordType { deposit, withdrawal, adjustment }

enum MoneyType { 
  physical, 
  digital 
}

class SavingsRecord {
  String id;
  double physicalAmount;
  double digitalAmount;
  String description;
  DateTime createdAt;
  RecordType type;
  String category;
  String? notes;

  SavingsRecord({
    required this.id,
    required this.physicalAmount,
    required this.digitalAmount,
    this.description = '',
    required this.createdAt,
    this.type = RecordType.deposit,
    this.category = 'General',
    this.notes,
  });

  double get totalAmount => physicalAmount + digitalAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'physicalAmount': physicalAmount,
      'digitalAmount': digitalAmount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'type': type.index,
      'category': category,
      'notes': notes,
    };
  }

  factory SavingsRecord.fromJson(Map<String, dynamic> json) {
    return SavingsRecord(
      id: json['id'],
      physicalAmount: (json['physicalAmount'] ?? 0).toDouble(),
      digitalAmount: (json['digitalAmount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      type: RecordType.values[json['type'] ?? 0],
      category: json['category'] ?? 'General',
      notes: json['notes'],
    );
  }

  SavingsRecord copyWith({
    String? id,
    double? physicalAmount,
    double? digitalAmount,
    String? description,
    DateTime? createdAt,
    RecordType? type,
    String? category,
    String? notes,
  }) {
    return SavingsRecord(
      id: id ?? this.id,
      physicalAmount: physicalAmount ?? this.physicalAmount,
      digitalAmount: digitalAmount ?? this.digitalAmount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SavingsRecord{id: $id, total: $totalAmount, category: $category, type: $type}';
  }
}