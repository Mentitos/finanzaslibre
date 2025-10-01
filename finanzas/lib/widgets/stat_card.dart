import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: onTap != null
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Valor principal
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 8),
              
              // Título
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Subtítulo opcional
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Widget especializado para mostrar dinero
class MoneyStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool showCurrency;

  const MoneyStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.onTap,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final displayColor = isNegative ? Colors.red : color;
    final formattedAmount = _formatCurrency(amount.abs());

    return StatCard(
      title: title,
      value: showCurrency ? '\$$formattedAmount' : formattedAmount,
      icon: icon,
      color: displayColor,
      onTap: onTap,
      subtitle: isNegative ? 'Saldo negativo' : null,
    );
  }

  String _formatCurrency(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// Widget para tarjetas de resumen con progreso
class ProgressStatCard extends StatelessWidget {
  final String title;
  final double currentValue;
  final double targetValue;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProgressStatCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y título
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progreso
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              
              const SizedBox(height: 8),
              
              // Valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_formatCurrency(currentValue)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              Text(
                'Meta: \$${_formatCurrency(targetValue)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}