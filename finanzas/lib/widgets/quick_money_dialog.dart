import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/savings_record.dart';

import '../services/user_manager.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (oldValue.text.length > newValue.text.length) {
      final String cleanOld = oldValue.text.replaceAll('.', '');
      final String cleanNew = newValue.text.replaceAll('.', '');

      if (cleanOld == cleanNew) {
        if (newValue.selection.baseOffset > 0) {
          final int deleteIndex = newValue.selection.baseOffset - 1;
          final String newTextRaw = newValue.text;

          final String newTextProcessed =
              newTextRaw.substring(0, deleteIndex) +
              newTextRaw.substring(deleteIndex + 1);

          String formatted = _formatWithThousands(newTextProcessed);

          int formattedCursor = 0;
          int digitCount = 0;
          for (int i = 0; i < formatted.length; i++) {
            if (digitCount >= deleteIndex) {
              break;
            }
            if (RegExp(r'\d').hasMatch(formatted[i])) {
              digitCount++;
            }
            formattedCursor++;
          }

          return TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formattedCursor),
          );
        }
      }
    }

    String text = newValue.text.replaceAll('.', '');

    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    String formatted = _formatWithThousands(text);

    int selectionIndex = newValue.selection.end;

    int newOffset = 0;
    int currentDigits = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (currentDigits >= selectionIndex) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        currentDigits++;
      }
      newOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  String _formatWithThousands(String text) {
    if (text.isEmpty) return text;

    String reversed = text.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }
}

class QuickMoneyDialog extends StatefulWidget {
  final MoneyType moneyType;
  final Function(SavingsRecord) onSave;
  final List<String> categories;
  final Map<String, Color>? categoryColors;
  final double currentAmount;
  final UserManager? userManager;

  const QuickMoneyDialog({
    super.key,
    required this.moneyType,
    required this.onSave,
    required this.categories,
    this.categoryColors,
    required this.currentAmount,
    this.userManager,
  });

  @override
  State<QuickMoneyDialog> createState() => _QuickMoneyDialogState();
}

class _QuickMoneyDialogState extends State<QuickMoneyDialog>
    with SingleTickerProviderStateMixin {
  final _depositFormKey = GlobalKey<FormState>();
  final _withdrawalFormKey = GlobalKey<FormState>();

  final _depositAmountController = TextEditingController();
  final _depositDescriptionController = TextEditingController();
  final _withdrawalAmountController = TextEditingController();
  final _withdrawalDescriptionController = TextEditingController();

  late TabController _tabController;
  String _depositCategory = 'General';
  String _withdrawalCategory = 'General';
  bool _isLoading = false;

  List<double> get quickAmounts => widget.moneyType == MoneyType.physical
      ? [1000, 2000, 5000, 10000, 20000, 50000]
      : [5000, 10000, 25000, 50000, 100000, 200000];

  int _depositLastSelection = 0;
  int _withdrawalLastSelection = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _depositCategory = widget.categories.first;
    _withdrawalCategory = widget.categories.first;

    _depositAmountController.addListener(_handleDepositSelection);
    _withdrawalAmountController.addListener(_handleWithdrawalSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _depositAmountController.removeListener(_handleDepositSelection);
    _withdrawalAmountController.removeListener(_handleWithdrawalSelection);
    _depositAmountController.dispose();
    _depositDescriptionController.dispose();
    _withdrawalAmountController.dispose();
    _withdrawalDescriptionController.dispose();
    super.dispose();
  }

  void _handleDepositSelection() =>
      _handleCursorSelection(_depositAmountController, isDeposit: true);

  void _handleWithdrawalSelection() =>
      _handleCursorSelection(_withdrawalAmountController, isDeposit: false);

  void _handleCursorSelection(
    TextEditingController controller, {
    required bool isDeposit,
  }) {
    final selection = controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return;

    final text = controller.text;
    final currentOffset = selection.baseOffset;
    final lastOffset = isDeposit
        ? _depositLastSelection
        : _withdrawalLastSelection;

    if (isDeposit) {
      _depositLastSelection = currentOffset;
    } else {
      _withdrawalLastSelection = currentOffset;
    }

    if (currentOffset > 0 &&
        currentOffset <= text.length &&
        text[currentOffset - 1] == '.') {
      if (currentOffset > lastOffset) {
        // 1 -> 1.2 (visual skip).

        // If I am at 2 (1.|2), I am technically at "Start of 2".
        // If I move to 3 (1.2|), I am "After 2".
        // So standard right movement 1->2 is correct for editing '2'.
        // But visually user might dislike the cursor "flashing" after dot.
        // But functionally it must be there to delete/add '2'.
      }

      // Let's try the user request: "Puntos no tocables".
      // Maybe they mean "If I click or arrive at dot, move me to the other side".
      // If I click 1.|234 -> Move to 1|.234.
      // If I Right Arrow from 1|.234 -> Land at 1.|234 -> Auto-move to 1?. Loop?
      // No, if I Right Arrow, I want to go to 2.
      // But 2 is "Start of 2".
      // Maybe I can't be at "Start of 2" if it implies "After dot"?
      // This is tricky. Text cursors exist between characters.

      // If I implement "Always left of dot":
      // 1.|234 -> Force to 1|.234.
      // Right Arrow from 1|.234 -> goes to 1.|234 -> Force back to 1|.234.
      // Result: Can't move right.

      // So we MUST distinguish "Right Movement" from "Click/Left Movement".
      // If (current > last) [Right Move]: Allow? Or Skip?
      // If we skip: 1|.234 -> Right -> 1.2|34 (Index 3).
      // We skipped '2'? That means we can't edit '2' easily?
      // We can backspace '2' from 3.
      // Can we insert before '2'?
      // If '1.234', and I want '1.5234'.
      // I need cursor at 2 (before 2).
      // If I skip to 3, I am after 2. Type 5 -> '1.2534'. Wrong.

      // Conclusion: "Untouchable dots" in a raw text field is mostly a backspace/delete UX thing.
      // Which I fixed.
      // The cursor "between 1 and ." is what the user asked for in previous turn.
      // "Clicking on dot" -> maybe nudge left?
      // If I Click at 2 (1.|234), nudge to 1 (1|.234).
      // If I Arrow to 2? Allow it?
      // The user says "points directly untouchable".

      // Let's implement: If selection lands after dot, move Left.
      // EXCEPT if we think it was a typed character? No, this is selection listener.
      // If we can't move right, that's bad.
      // But maybe the "Right Arrow" skips the dot AND the next char? No.

      // Alternative: Virtualize the dots.
      // But we are using a TextField.

      // Let's look at the user prompt again: "cursor entre el 1 y el ." (between 1 and dot).
      // "que los puntos directamente no sean tocables... esteticos".

      // If I move cursor right from 1.
      // It normally lands at 2 (1.|2).
      // If I force it to 3 (1.2|), I skip being able to insert before 2.
      // UNLESS... typing at 3 inserts before 2? No.

      // Maybe the user is OK with "Right arrow jumps dot"?
      // If I am at 1 (1.|2), and I type '5'.
      // Formatter sees '1.52...' -> '15.2...'.
      // It works.

      // What if I implement: If cursor is after dot, move to before dot.
      // AND modify formatter or something? No.

      // Let's assume the user is happy with "Clicking/Landing on dot moves to Left".
      // And we accept that Right Arrow might get stuck or skip?
      // If I make specific logic:
      // If (Moving Right) -> Skip to 1.2|?
      //    This means I can't insert before 2.
      //    Is that acceptable?
      //    "Currency format" implies filling from right? Or typing?
      //    This is a "custom amount" field. Standard typing.

      // Let's stick to: "If I land explicitly on the dot (click?), move left".
      // How to distinguish click from arrow?
      // Change in offset > 1? Or just logic.
      // I will implement "Jump Left" strategy.
      // As for "Right Arrow stuck", I'll test it mentally:
      // 1|.2 -> Right -> 1.|2 -> Detected -> 1|.2. STUCK.

      // Okay, "Jump Right" strategy for Right Move?
      // 1|.2 -> Right -> 1.|2 -> Detected (Moving Right) -> Jump +1 -> 1.2| ?
      // If I jump to 1.2|, I am after 2.
      // I can't insert before 2.

      // Maybe the user just means "Don't select the dot".
      // Selection range? collapsed.

      // I will implement: "If cursor is after dot, move it to before dot" ONLY IF not moving right?
      // No...

      // Recommendation: standard "untouchable" implementation allows cursor adjacent, but BACKSPACE skips it (done).
      // Maybe "Delete" (forward) skips it.
      // Maybe I just implement "Click adjustments".
      // If (currentOffset != lastOffset + 1 && currentOffset != lastOffset - 1) { // Likely a click or jump }

      // I will implement: If (abs(delta) > 1) { // Click or long jump
      //   If char at offset-1 is '.', move offset - 1.
      // }

      if ((currentOffset - lastOffset).abs() > 1) {
        // Likely a click
        final newSelection = TextSelection.collapsed(offset: currentOffset - 1);
        controller.selection = newSelection;
        // Update last selection
        if (isDeposit)
          _depositLastSelection = currentOffset - 1;
        else
          _withdrawalLastSelection = currentOffset - 1;
      }
    }
  }

  String _getMoneyTypeLabel(AppLocalizations l10n) =>
      widget.moneyType == MoneyType.physical
      ? l10n.physicalMoney
      : l10n.digitalMoney;

  IconData get _moneyTypeIcon => widget.moneyType == MoneyType.physical
      ? Icons.account_balance_wallet
      : Icons.credit_card;

  Color get _moneyTypeColor => widget.moneyType == MoneyType.physical
      ? AppConstants.physicalMoneyColor
      : AppConstants.digitalMoneyColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDepositTab(), _buildWithdrawalTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = widget.userManager?.getCurrentUserSync();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _moneyTypeColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeBorderRadius),
          topRight: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _moneyTypeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_moneyTypeIcon, color: _moneyTypeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quickDepositWithdrawal,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      _getMoneyTypeLabel(l10n),
                      style: TextStyle(
                        color: _moneyTypeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (currentUser != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${currentUser.name}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedLabelColor: isDark ? Colors.grey[300] : Colors.grey[600],
        tabs: [
          Tab(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            text: l10n.deposit,
          ),
          Tab(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            text: l10n.withdrawal,
          ),
        ],
      ),
    );
  }

  Widget _buildDepositTab() {
    return _buildTabContent(
      RecordType.deposit,
      _depositFormKey,
      _depositAmountController,
      _depositDescriptionController,
      _depositCategory,
      (value) => setState(() => _depositCategory = value),
    );
  }

  Widget _buildWithdrawalTab() {
    return _buildTabContent(
      RecordType.withdrawal,
      _withdrawalFormKey,
      _withdrawalAmountController,
      _withdrawalDescriptionController,
      _withdrawalCategory,
      (value) => setState(() => _withdrawalCategory = value),
    );
  }

  Widget _buildTabContent(
    RecordType type,
    GlobalKey<FormState> formKey,
    TextEditingController amountController,
    TextEditingController descriptionController,
    String selectedCategory,
    Function(String) onCategoryChanged,
  ) {
    final isDeposit = type == RecordType.deposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final icon = isDeposit ? Icons.add_circle : Icons.remove_circle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentBalanceCard(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildQuickAmountsSection(amountController),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildAmountField(amountController),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildCategorySelector(selectedCategory, onCategoryChanged),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildDescriptionField(descriptionController),
            const SizedBox(height: AppConstants.largePadding),
            _buildActionButtons(
              type,
              color,
              icon,
              formKey,
              amountController,
              descriptionController,
              selectedCategory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _moneyTypeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: _moneyTypeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(_moneyTypeIcon, color: _moneyTypeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '${l10n.currentBalance}: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$${Formatters.formatCurrency(widget.currentAmount)}',
                style: TextStyle(
                  color: _moneyTypeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountsSection(TextEditingController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickAmounts,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts
              .map((amount) => _buildQuickAmountChip(amount, controller))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChip(
    double amount,
    TextEditingController controller,
  ) {
    return ActionChip(
      label: Text(
        '\$${Formatters.formatCurrency(amount)}',
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        setState(() {
          String amountStr = amount.toStringAsFixed(0);
          controller.text = _formatNumberWithDots(amountStr);
        });
      },
      backgroundColor: _moneyTypeColor.withOpacity(0.1),
      side: BorderSide(color: _moneyTypeColor.withOpacity(0.3)),
    );
  }

  String _formatNumberWithDots(String number) {
    if (number.isEmpty) return number;
    String reversed = number.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }

  Widget _buildAmountField(TextEditingController controller) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.customAmount,
        prefixText: '\$',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(_moneyTypeIcon, color: _moneyTypeColor),
        helperText: l10n.enterAmountOrSelectQuick,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),

        ThousandsSeparatorInputFormatter(),

        LengthLimitingTextInputFormatter(25),
      ],
      validator: (value) {
        if (value?.isEmpty == true) {
          return l10n.enterAmount;
        }

        final cleanValue = value!.replaceAll('.', '');
        final amount = double.tryParse(cleanValue);
        if (amount == null || amount <= 0) {
          return l10n.enterValidAmount;
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector(
    String selectedCategory,
    Function(String) onChanged,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.category),
      ),
      items: widget.categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppConstants.getCategoryColor(
                        category,
                        widget.categoryColors,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.translateCategory(category),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (value) => onChanged(value!),
      validator: (value) => value == null ? l10n.selectCategory : null,
    );
  }

  Widget _buildDescriptionField(TextEditingController controller) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.descriptionOptional,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.description),
        hintText: l10n.descriptionHint,
      ),
      maxLines: 2,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildActionButtons(
    RecordType type,
    Color color,
    IconData icon,
    GlobalKey<FormState> formKey,
    TextEditingController amountController,
    TextEditingController descriptionController,
    String selectedCategory,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDeposit = type == RecordType.deposit;
    final actionText = isDeposit ? l10n.makeDeposit : l10n.makeWithdrawal;

    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: Text(l10n.cancel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _isLoading
                ? null
                : () => _saveRecord(
                    type,
                    formKey,
                    amountController,
                    descriptionController,
                    selectedCategory,
                  ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon),
            label: Text(_isLoading ? l10n.saving : actionText),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _saveRecord(
    RecordType type,
    GlobalKey<FormState> formKey,
    TextEditingController amountController,
    TextEditingController descriptionController,
    String selectedCategory,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final cleanAmount = amountController.text.replaceAll('.', '');
    final amount = double.parse(cleanAmount);
    final moneyTypeLabel = _getMoneyTypeLabel(l10n).toLowerCase();

    final record = SavingsRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      physicalAmount: widget.moneyType == MoneyType.physical ? amount : 0,
      digitalAmount: widget.moneyType == MoneyType.digital ? amount : 0,
      description: descriptionController.text.trim().isEmpty
          ? '${type == RecordType.deposit ? l10n.deposit : l10n.withdrawal} ${l10n.quick.toLowerCase()} $moneyTypeLabel'
          : descriptionController.text.trim(),
      createdAt: DateTime.now(),
      type: type,
      category: selectedCategory,
    );

    widget.onSave(record);

    if (mounted) {
      Navigator.pop(context);

      final typeLabel = type == RecordType.deposit
          ? l10n.deposit
          : l10n.withdrawal;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.transactionCompleted(
              typeLabel,
              Formatters.formatCurrency(amount),
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
