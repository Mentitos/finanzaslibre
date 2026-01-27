import 'savings_record.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly, custom }

enum RecurringUnit { second, minute, hour, day, week, month, year }

class RecurringTransaction {
  String id;
  String name;
  double physicalAmount;
  double digitalAmount;
  RecordType type;
  String category;
  String description;

  RecurringFrequency frequency;
  int? recurrenceDay; // For monthly fixed day

  // Custom Frequency Fields
  int? customInterval;
  RecurringUnit? customUnit;

  bool autoPay; // New field for automatic processing

  DateTime? startDate;
  DateTime? lastProcessedDate;

  RecurringTransaction({
    required this.id,
    required this.name,
    required this.physicalAmount,
    required this.digitalAmount,
    this.type = RecordType.withdrawal,
    this.category = 'General',
    this.description = '',
    this.frequency = RecurringFrequency.monthly,
    this.recurrenceDay,
    this.customInterval,
    this.customUnit,
    this.autoPay = false,
    this.startDate,
    this.lastProcessedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'physicalAmount': physicalAmount,
      'digitalAmount': digitalAmount,
      'type': type.index,
      'category': category,
      'description': description,
      'frequency': frequency.index,
      'recurrenceDay': recurrenceDay,
      'customInterval': customInterval,
      'customUnit': customUnit?.index,
      'autoPay': autoPay,
      'startDate': startDate?.toIso8601String(),
      'lastProcessedDate': lastProcessedDate?.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      name: json['name'],
      physicalAmount: (json['physicalAmount'] ?? 0).toDouble(),
      digitalAmount: (json['digitalAmount'] ?? 0).toDouble(),
      type: RecordType.values[json['type'] ?? 1],
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      frequency: RecurringFrequency.values[json['frequency'] ?? 2],
      recurrenceDay: json['recurrenceDay'],
      customInterval: json['customInterval'],
      customUnit: json['customUnit'] != null
          ? RecurringUnit.values[json['customUnit']]
          : null,
      autoPay: json['autoPay'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      lastProcessedDate: json['lastProcessedDate'] != null
          ? DateTime.parse(json['lastProcessedDate'])
          : null,
    );
  }

  bool isDue() {
    final now = DateTime.now();
    // For seconds/minutes/hours, we need high precision.
    // If unit is sub-day (second, minute, hour), compare full DateTime.
    // Ideally, we compare timestamps.

    // If never processed, check start date
    if (lastProcessedDate == null) {
      if (startDate == null) return true;
      // If start date is in past or now, it's due.
      return !startDate!.isAfter(now);
    }

    final nextDue = getNextDueDate();
    // Use 'isBefore' or 'isAtSameMomentAs' check
    return !nextDue.isAfter(now);
  }

  DateTime getNextDueDate() {
    final now = DateTime.now();
    DateTime baseDate = lastProcessedDate ?? startDate ?? now;

    switch (frequency) {
      case RecurringFrequency.daily:
        return baseDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return baseDate.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        // Existing monthly logic (keeps day of month if possible)
        int targetDay = recurrenceDay ?? baseDate.day;
        int nextYear = baseDate.year;
        int nextMonth = baseDate.month + 1;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        int daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        int actualDay = targetDay > daysInMonth ? daysInMonth : targetDay;
        // Keep time components if needed, or reset to start of day?
        // Let's keep time components for consistency if baseDate had them.
        return DateTime(
          nextYear,
          nextMonth,
          actualDay,
          baseDate.hour,
          baseDate.minute,
          baseDate.second,
        );
      case RecurringFrequency.yearly:
        return DateTime(
          baseDate.year + 1,
          baseDate.month,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
          baseDate.second,
        );
      case RecurringFrequency.custom:
        final interval = customInterval ?? 1;
        final unit = customUnit ?? RecurringUnit.day;

        switch (unit) {
          case RecurringUnit.second:
            return baseDate.add(Duration(seconds: interval));
          case RecurringUnit.minute:
            return baseDate.add(Duration(minutes: interval));
          case RecurringUnit.hour:
            return baseDate.add(Duration(hours: interval));
          case RecurringUnit.day:
            return baseDate.add(Duration(days: interval));
          case RecurringUnit.week:
            return baseDate.add(Duration(days: interval * 7));
          case RecurringUnit.month:
            // Simple month add
            int nextYear = baseDate.year;
            int nextMonth = baseDate.month + interval;
            // Handle overflow year
            while (nextMonth > 12) {
              nextMonth -= 12;
              nextYear++;
            }
            // Handle end of month (e.g. 31st Jan + 1 month -> 28th Feb)
            int daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            int actualDay = baseDate.day > daysInMonth
                ? daysInMonth
                : baseDate.day;
            return DateTime(
              nextYear,
              nextMonth,
              actualDay,
              baseDate.hour,
              baseDate.minute,
              baseDate.second,
            );
          case RecurringUnit.year:
            return DateTime(
              baseDate.year + interval,
              baseDate.month,
              baseDate.day,
              baseDate.hour,
              baseDate.minute,
              baseDate.second,
            );
        }
    }
  }

  int getDaysRemaining() {
    final now = DateTime.now();
    final next = getNextDueDate();
    final diff = next.difference(now);

    // If it's sub-day precision and overdue (negative), return 0 if creating today
    // But for "Days Remaining" UI, let's keep using days.
    // If we want countdown for seconds/minutes, we'd need a Timer which is overkill for list.
    // Just return days for list view.
    return diff.inDays;
  }

  String getDaysRemainingText() {
    final days = getDaysRemaining();
    if (days < 0) return 'Vencido hace ${days.abs()} días';
    if (days == 0) {
      // Check if it's actually due TODAY in the future (hours left) or overdue (hours ago)
      final now = DateTime.now();
      final next = getNextDueDate();
      final diff = next.difference(now);

      if (diff.isNegative) return '¡Vence ahora!';

      if (diff.inHours > 0) return 'Faltan ${diff.inHours} horas';
      if (diff.inMinutes > 0) return 'Faltan ${diff.inMinutes} minutos';
      if (diff.inSeconds > 0) return 'Faltan ${diff.inSeconds} segundos';
      return 'Vence ahora';
    }
    return 'Faltan $days días';
  }
}
