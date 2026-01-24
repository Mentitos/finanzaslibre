// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Libre Finance';

  @override
  String get appName => 'Libre Finance';

  @override
  String get appDescription => 'Your savings management companion';

  @override
  String get googleDriveSync => 'Google Drive';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signOut => 'Sign Out';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get backupsAvailable => 'Available Backups';

  @override
  String get noBackupsYet => 'No Backups Available';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String get backupUploaded => 'Backup uploaded successfully';

  @override
  String get backupRestored => 'Backup restored successfully';

  @override
  String get backupDeleted => 'Backup deleted';

  @override
  String get goals => 'Goals';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get newGoal => 'New Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get goalCompleted => 'Goal Completed';

  @override
  String get addMoney => 'Add Money';

  @override
  String get removeMoney => 'Remove Money';

  @override
  String get googleDriveSyncSubtitle => 'Sync your data to the cloud';

  @override
  String get summary => 'Summary';

  @override
  String get history => 'History';

  @override
  String get categories => 'Categories';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get physicalMoney => 'Physical Money';

  @override
  String get digitalMoney => 'Digital Money';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get balance => 'Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get addRecord => 'Add Record';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get notes => 'Notes';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get emptyRecords => 'No records yet';

  @override
  String get emptyRecordsSubtitle => 'Add your first savings record!';

  @override
  String get emptySearch => 'No results found';

  @override
  String get emptySearchSubtitle => 'Try different search terms';

  @override
  String get emptyCategory => 'No records in this category';

  @override
  String get emptyCategorySubtitle => 'Add records to this category';

  @override
  String get deleteRecordConfirm =>
      'Are you sure you want to delete this record?';

  @override
  String get deleteCategoryConfirm => 'Delete category';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataConfirm =>
      'Are you sure? This action cannot be undone';

  @override
  String get recordSaved => 'Record saved successfully';

  @override
  String get recordUpdated => 'Record updated successfully';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get genericError => 'An unexpected error occurred';

  @override
  String get saveError => 'Error saving data';

  @override
  String get loadError => 'Error loading data';

  @override
  String get validationError => 'Please check the entered data';

  @override
  String get categoryInUse => 'Category in use';

  @override
  String get categoryExists => 'Category already exists';

  @override
  String get emptyAmount => 'You must enter at least one amount';

  @override
  String get allFilter => 'All';

  @override
  String get deposits => 'Deposits';

  @override
  String get withdrawals => 'Withdrawals';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String weeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String monthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String yearsAgo(Object count) {
    return '$count years ago';
  }

  @override
  String get lastMovement => 'Last movement';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get recentMovements => 'Recent Movements';

  @override
  String get viewAll => 'View all';

  @override
  String get searchRecords => 'Search records...';

  @override
  String get allCategories => 'All categories';

  @override
  String get noRecords => 'No records';

  @override
  String get noRecordsSubtitle => 'Start by adding your first transaction';

  @override
  String get noSearchResults => 'No results';

  @override
  String get noSearchResultsSubtitle => 'No matches found';

  @override
  String get noCategoryRecords => 'Empty category';

  @override
  String get noCategoryRecordsSubtitle => 'No records in this category';

  @override
  String get deleteConfirmation => 'Delete?';

  @override
  String get savingsByCategory => 'Savings by Category';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get recordsWillBeMoved => 'record(s) will be moved to General';

  @override
  String get currentAmount => 'Current amount';

  @override
  String get moveAndDelete => 'Move and Delete';

  @override
  String get newCategory => 'New Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get chooseColor => 'Choose a color';

  @override
  String get categoryPreview => 'Category preview';

  @override
  String get invalidCategoryName => 'Invalid category name';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get new_ => 'New';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeOn => 'Dark theme enabled';

  @override
  String get lightModeOn => 'Light theme enabled';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle => 'Save backup of your records';

  @override
  String get importData => 'Import data';

  @override
  String get importDataSubtitle => 'Restore from a backup';

  @override
  String get dataExportSuccess => 'Data exported successfully';

  @override
  String get dataExportError => 'Error exporting data';

  @override
  String get dataExported => 'Data exported';

  @override
  String get exportInstructions =>
      'Copy this data and save it in a safe place:';

  @override
  String get pasteExportedData => 'Paste the exported data here:';

  @override
  String get dataImportedSuccessfully => 'Data imported successfully';

  @override
  String get errorImportingData => 'Error importing data';

  @override
  String get invalidDataFormat => 'Invalid data format';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAllRecords => 'Delete all records';

  @override
  String get deleteAllRecordsSubtitle => 'Clear history keeping categories';

  @override
  String get resetApp => 'Reset application';

  @override
  String get resetAppSubtitle => 'Delete everything and start over';

  @override
  String get deleteRecordsTitle => 'Delete records';

  @override
  String get deleteRecordsSubtitle =>
      'Are you sure you want to delete all records?\n\nThis action cannot be undone. Categories will remain.';

  @override
  String get allRecordsDeleted => 'All records deleted';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get resetAppTitle => 'Reset app';

  @override
  String get resetAppSubtext =>
      'Are you sure you want to reset the app?\n\nThis will delete:\n• All records\n• All custom categories\n• All settings\n\nThis action CANNOT be undone.';

  @override
  String get appReset => 'App reset';

  @override
  String get reset => 'Reset';

  @override
  String get security => 'Security';

  @override
  String get pinSecurityTitle => 'Security PIN';

  @override
  String get pinActiveSubtitle => 'Active protection with a 4-digit PIN';

  @override
  String get pinInactiveSubtitle => 'Protect your app with a PIN';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get changePinSubtitle => 'Modify your current PIN';

  @override
  String get pinSetupSuccess => 'PIN set up successfully';

  @override
  String get noPinConfigured => 'No PIN configured';

  @override
  String get pinUpdated => 'PIN updated successfully';

  @override
  String get pinDisabled => 'PIN disabled';

  @override
  String get disablePinTitle => 'Disable PIN';

  @override
  String get disablePinSubtitle =>
      'Are you sure you want to disable PIN protection?\n\nYour data will be left unprotected.';

  @override
  String get disable => 'Disable';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get specificMonth => 'Specific month';

  @override
  String get specificDay => 'Specific day';

  @override
  String get specificYear => 'Specific year';

  @override
  String get distributionByCategory => 'Distribution by category';

  @override
  String get categoryDetails => 'Category details';

  @override
  String get ofTotal => 'of total';

  @override
  String get selectMonth => 'Select month';

  @override
  String get year => 'Year';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get openSourceProject => 'Open Source Project';

  @override
  String get openSourceDescription =>
      'This project is open source. You can view the repository at';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get creator => 'Creator';

  @override
  String get supportProject => 'Support the Project';

  @override
  String get donateUala =>
      'If you want to support, you can donate via PayPal or Ualá(Argentina only)';

  @override
  String get aliasCopied => 'Alias copied';

  @override
  String get features => 'Features';

  @override
  String get feature1 => 'Management of physical and digital money';

  @override
  String get feature2 => 'Customizable categories';

  @override
  String get feature3 => 'Complete transaction history';

  @override
  String get feature4 => 'Detailed statistics';

  @override
  String get feature5 => 'Data export and import';

  @override
  String get feature6 => 'Feedback and support';

  @override
  String get dataStoredLocally => 'Your data is stored locally on your device';

  @override
  String get close => 'Close';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get createPin => 'Create PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get confirmNewPin => 'Confirm your new PIN';

  @override
  String get createPinDigits => 'Create a 4-digit PIN';

  @override
  String get biometricUnlock => 'Biometric Unlock';

  @override
  String get useFingerprintOrFace => 'Use fingerprint or Face ID';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get biometricAuthReason => 'Use your fingerprint or Face ID to enter';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue';

  @override
  String failedAttempts(Object count) {
    return 'Failed attempts: $count';
  }

  @override
  String get tooManyAttempts => 'Too many attempts';

  @override
  String get tooManyAttemptsMessage =>
      'You have failed 5 attempts. The app will close.';

  @override
  String get understood => 'Understood';

  @override
  String get quickDepositWithdrawal => 'Quick Deposit/Withdrawal';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get quickAmounts => 'Quick Amounts';

  @override
  String get customAmount => 'Custom Amount';

  @override
  String get enterAmountOrSelectQuick =>
      'Enter the amount or select a quick one above';

  @override
  String get enterAmount => 'Enter an amount';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get descriptionHint => 'E.g.: Grocery shopping, bill payment...';

  @override
  String get makeDeposit => 'Deposit';

  @override
  String get makeWithdrawal => 'Withdraw';

  @override
  String transactionCompleted(String type, String amount) {
    return '$type of \$$amount completed';
  }

  @override
  String get saving => 'Thinking...';

  @override
  String get quick => 'quick';

  @override
  String get newRecord => 'New Record';

  @override
  String get operationType => 'Operation Type';

  @override
  String get amounts => 'Amounts';

  @override
  String get enterAtLeastOneAmount => 'Enter at least one amount';

  @override
  String get descriptionHintRecord =>
      'E.g.: Monthly savings, various expenses...';

  @override
  String get additionalNotes => 'Additional Notes (optional)';

  @override
  String get additionalNotesHint => 'Extra information...';

  @override
  String get update => 'Update';

  @override
  String get mustEnterAtLeastOneAmount => 'Please enter at least one amount';

  @override
  String get depositUpper => 'DEPOSIT';

  @override
  String get withdrawalUpper => 'WITHDRAWAL';

  @override
  String get adjustmentUpper => 'ADJUST';

  @override
  String get newBalance => 'New Balance';

  @override
  String get adjustmentInfo =>
      'Enter the new total balance for physical or digital money.';

  @override
  String get adjustment => 'Adjustment';

  @override
  String get systemLanguage => 'System language';

  @override
  String get system => 'system';

  @override
  String get systemDefault => 'default system';

  @override
  String get users => 'Users';

  @override
  String get addUser => 'Add user';

  @override
  String get enterUserName => 'Enter user name';

  @override
  String get create => 'Create';

  @override
  String get deleteUser => 'Delete user';

  @override
  String get deleteUserConfirmation => 'Are you sure you want to delete user';

  @override
  String get userCreated => 'User created';

  @override
  String get userDeleted => 'User deleted';

  @override
  String get currentUser => 'Current user';

  @override
  String get switchedTo => 'Switched to';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get selectFromGallery => 'Select from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get photoRemoved => 'Photo removed';

  @override
  String get error => 'Error';

  @override
  String get principal => 'Main';

  @override
  String get selectExportFormat => 'Select export format:';

  @override
  String get standardDataFormat => 'Standard data format';

  @override
  String get simpleSpreadsheetFormat => 'Simple spreadsheet format';

  @override
  String get excelFormatWithMultipleSheets =>
      'Excel format with multiple sheets';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get jsonFormat => 'JSON Format:';

  @override
  String get jsonCopiedToClipboard => 'JSON copied to clipboard';

  @override
  String fileSaved(String filename) {
    return 'File saved: $filename';
  }

  @override
  String get pathCopied => 'Path copied';

  @override
  String get onlyJsonCanBeImported =>
      'Only JSON data can be imported in this app';

  @override
  String get onlyJsonFilesAccepted =>
      'Only JSON files exported from this app are accepted';

  @override
  String get jsonPastedFromClipboard => 'JSON pasted from clipboard';

  @override
  String get noTextInClipboard => 'No text in clipboard';

  @override
  String get jsonFileLoaded => 'JSON file loaded';

  @override
  String get errorOpeningFile => 'Error opening file';

  @override
  String get paste => 'Paste';

  @override
  String get file => 'File';

  @override
  String get download => 'Download';

  @override
  String get copy => 'Copy';

  @override
  String get manageUsersWallets => 'Manage users wallets';

  @override
  String get preferences => 'Preferences';

  @override
  String get appearanceNotificationsSecurity =>
      'Appearance, notifications and security';

  @override
  String get data => 'Data';

  @override
  String get exportImportManageData => 'Export, import and manage your data';

  @override
  String get dataManagementTitle => 'Data management';

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get clearRecordsConfirmation =>
      'All records for the current user will be deleted. This action cannot be undone.';

  @override
  String get recordsDeleted => 'Records deleted';

  @override
  String get resetAppCompletelyMessage =>
      'The application will be completely reset.';

  @override
  String get alwaysKept => 'Will always be kept:';

  @override
  String get mainWalletKept => '✓ Your main wallet \"My Wallet\"';

  @override
  String get userProfileKept => '✓ Your user profile';

  @override
  String get keepRecordsOption => 'Keep records';

  @override
  String get keepMainWalletHistory => 'Keep the main wallet history';

  @override
  String get willBeDeleted => 'Will be deleted:';

  @override
  String get additionalWalletsDeleted => '✗ All additional wallets';

  @override
  String get customCategoriesDeleted => '✗ All custom categories';

  @override
  String get allRecordsHistoryDeleted => '✗ All records and history';

  @override
  String get allCategoriesDeleted => '✗ All categories';

  @override
  String get appResetWithRecordsKept =>
      'Application reset. Your main wallet is kept with all its records.';

  @override
  String get appResetAsNew =>
      'Application reset as new. Your main wallet is empty.';

  @override
  String get copyPath => 'Copy path';

  @override
  String get share => 'Share';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get reminderEnabled => 'You will receive a reminder every day';

  @override
  String get reminderDisabled => 'Reminders are disabled';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get notificationPermissionRequired =>
      'Notification permissions are required';

  @override
  String reminderActivatedAt(Object time) {
    return 'Reminder activated for $time';
  }

  @override
  String timeUpdated(Object time) {
    return 'Time updated: $time';
  }

  @override
  String get reminderDeactivated => 'Reminder deactivated';

  @override
  String get savingsReminderTitle => '💰 Savings Reminder';

  @override
  String get savingsReminderBody =>
      'Have you recorded your transactions today?';

  @override
  String get holdToDelete => 'Hold to delete';

  @override
  String get editUserName => 'Edit name';

  @override
  String get useThisWallet => 'Use this wallet';

  @override
  String alreadyUsingUser(String name) {
    return 'You were already using $name';
  }

  @override
  String get enterNewUserName => 'Enter the new name';

  @override
  String nameUpdatedTo(String newName) {
    return 'Name updated to: $newName';
  }

  @override
  String get accounts => 'Accounts';

  @override
  String get userManagement => 'User Management';

  @override
  String get manageUsersAndWallets =>
      'Manage users and switch between different wallets.';
}
