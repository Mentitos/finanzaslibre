import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class Formatters {
  
 
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'de_DE');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCurrencyWithSign(double amount, {bool showPositiveSign = true}) {
    final formatted = formatCurrency(amount.abs());
    if (amount > 0 && showPositiveSign) {
      return '+\$$formatted';
    } else if (amount < 0) {
      return '-\$$formatted';
    } else {
      return '\$$formatted';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatRelativeDate(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = today.difference(date).inDays;

    if (difference == 0) {
      return '${l10n.today} ${formatTime(dateTime)}';
    } else if (difference == 1) {
      return '${l10n.yesterday} ${formatTime(dateTime)}';
    } else if (difference <= 7) {
      return l10n.daysAgo(difference);
    } else {
      return formatDate(dateTime);
    }
  }

  static String formatPercentage(double value, {int decimals = 2}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  static String formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n.weeksAgo(weeks);
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return l10n.monthsAgo(months);
    } else {
      final years = (difference.inDays / 365).floor();
      return l10n.yearsAgo(years);
    }
  }

  static bool isValidNumber(String text) {
    return double.tryParse(text) != null;
  }

  static double parseDouble(String text, {double defaultValue = 0.0}) {
    return double.tryParse(text) ?? defaultValue;
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatDateRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatDate(start);
    } else if (isSameMonth(start, end)) {
      return '${start.day} - ${end.day}/${end.month}/${end.year}';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static String getMonthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december
    ];
    return months[month - 1];
  }

  static String getDayName(int weekday, AppLocalizations l10n) {
    final days = [
      l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday,
      l10n.friday, l10n.saturday, l10n.sunday
    ];
    return days[weekday - 1];
  }
  
}
