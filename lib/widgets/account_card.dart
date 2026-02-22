import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../services/security_service.dart';
import '../providers/settings_provider.dart';
import '../services/localization_service.dart';
import 'package:flutter/services.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({
    super.key,
    required this.account,
  });

  Future<void> _showAccountDetails(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    
    if (settings.biometricEnabled) {
      final authenticated = await SecurityService.authenticate();
      if (!authenticated) return;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AccountDetailsSheet(account: account),
    );
  }

  IconData _getCategoryIcon(String category) {
    // Priority logic for common services
    final name = account.serviceName.toLowerCase();
    if (name.contains('google') || name.contains('gmail')) return Icons.mail_rounded;
    if (name.contains('facebook')) return Icons.facebook;
    if (name.contains('apple')) return Icons.apple;
    if (name.contains('instagram')) return Icons.camera_alt_rounded;
    if (name.contains('twitter') || name.contains(' x ')) return Icons.close_rounded;
    if (name.contains('github')) return Icons.code_rounded;

    return switch (category) {
      'Social Media' => Icons.people_rounded,
      'Entertainment' => Icons.movie_rounded,
      'Work/Email' => Icons.work_rounded,
      'Finance' => Icons.account_balance_rounded,
      'Games' => Icons.sports_esports_rounded,
      'Shopping' => Icons.shopping_cart_rounded,
      _ => Icons.category_rounded,
    };
  }

  Color _getBrandColor(String category) {
    return switch (category) {
      'Social Media' => const Color(0xFF1877F2),
      'Entertainment' => const Color(0xFFE50914),
      'Work/Email' => const Color(0xFF34A853),
      'Finance' => const Color(0xFFFBBC05),
      'Games' => const Color(0xFF6C63FF),
      'Shopping' => const Color(0xFFFF9900),
      _ => const Color(0xFF6C63FF),
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);
    final categoryIcon = _getCategoryIcon(account.category ?? 'Other');
    final brandColor = _getBrandColor(account.category ?? 'Other');

    return Card(
      child: InkWell(
        onTap: () => _showAccountDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: brandColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    categoryIcon,
                    color: brandColor,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          account.serviceName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: brandColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            loc.getLocalizedCategory(account.category ?? 'Other'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: brandColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.username,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmDialog(context, loc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppLocalization loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(loc.translate('delete_title')),
        content: Text('${loc.translate('delete_confirm')} ${account.serviceName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('no_way')),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountProvider>().deleteAccount(account);
              Navigator.pop(context);
            },
            child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsSheet extends StatefulWidget {
  final Account account;
  const _AccountDetailsSheet({required this.account});

  @override
  State<_AccountDetailsSheet> createState() => _AccountDetailsSheetState();
}

class _AccountDetailsSheetState extends State<_AccountDetailsSheet> {
  bool _obscurePassword = true;

  final Map<String, IconData> _categories = {
    'Social Media': Icons.people_rounded,
    'Entertainment': Icons.movie_rounded,
    'Work/Email': Icons.work_rounded,
    'Finance': Icons.account_balance_rounded,
    'Games': Icons.sports_esports_rounded,
    'Shopping': Icons.shopping_cart_rounded,
    'Other': Icons.category_rounded,
  };

  IconData _getCategoryIcon(String category) {
    return _categories[category] ?? Icons.category_rounded;
  }

  void _showCategoryPicker(BuildContext context, AppLocalization loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.translate('change_category'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _categories.keys.map((cat) => ListTile(
                  leading: Icon(_categories[cat], color: const Color(0xFF6C63FF)),
                  title: Text(loc.getLocalizedCategory(cat)),
                  onTap: () {
                    context.read<AccountProvider>().updateAccountCategory(widget.account, cat);
                    Navigator.pop(context); // Close picker
                    Navigator.pop(context); // Close details sheet to refresh
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getCategoryIcon(widget.account.category ?? 'Other'), color: Theme.of(context).colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _showCategoryPicker(context, loc),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withAlpha(60),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(widget.account.category ?? 'Other'), 
                              size: 14, 
                              color: Theme.of(context).colorScheme.primary
                            ),
                            const SizedBox(width: 6),
                            Text(
                              loc.getLocalizedCategory(widget.account.category ?? 'Other'), 
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded, 
                              size: 12, 
                              color: Theme.of(context).colorScheme.primary.withAlpha(180)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildDetailItem(context, loc.translate('username_email'), widget.account.username, loc),
          const SizedBox(height: 16),
          _buildDetailItem(
            context,
            loc.translate('password'),
            widget.account.password,
            loc,
            isPassword: true,
            obscure: _obscurePassword,
            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          if (widget.account.notes != null) ...[
            const SizedBox(height: 16),
            _buildDetailItem(context, loc.translate('notes'), widget.account.notes!, loc),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(loc.translate('close'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    AppLocalization loc, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.translate('copied')), duration: const Duration(seconds: 1)),
                );
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2C2C2C) 
                : Colors.grey.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isPassword && obscure ? '•' * 12 : value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                    fontSize: 16, 
                    letterSpacing: isPassword && obscure ? 2 : 1
                  ),
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
