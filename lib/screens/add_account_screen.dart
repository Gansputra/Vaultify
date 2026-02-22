import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../services/localization_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/aura_background.dart';
import 'dart:ui';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePassword = true;

  String _selectedCategory = 'Other';
  final Map<String, IconData> _categories = {
    'Social Media': Icons.people_rounded,
    'Entertainment': Icons.movie_rounded,
    'Work/Email': Icons.work_rounded,
    'Finance': Icons.account_balance_rounded,
    'Games': Icons.sports_esports_rounded,
    'Shopping': Icons.shopping_cart_rounded,
    'Other': Icons.category_rounded,
  };

  @override
  void initState() {
    super.initState();
    _serviceController.addListener(_autoDetectCategory);
  }

  @override
  void dispose() {
    _serviceController.removeListener(_autoDetectCategory);
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _autoDetectCategory() {
    final name = _serviceController.text.toLowerCase();
    String detected = 'Other';

    if (name.contains('facebook') || name.contains('instagram') || name.contains('twitter') || 
        name.contains('tiktok') || name.contains('whatsapp') || name.contains('linkedin') || 
        name.contains('tele') || name.contains('snapchat')) {
      detected = 'Social Media';
    } else if (name.contains('netflix') || name.contains('spotify') || name.contains('disney') || 
               name.contains('hulu') || name.contains('youtube') || name.contains('prime')) {
      detected = 'Entertainment';
    } else if (name.contains('google') || name.contains('gmail') || name.contains('outlook') || 
               name.contains('work') || name.contains('slack') || name.contains('zoom') || 
               name.contains('mail') || name.contains('github')) {
      detected = 'Work/Email';
    } else if (name.contains('bca') || name.contains('mandiri') || name.contains('bri') || 
               name.contains('paypal') || name.contains('binance') || name.contains('bank') || 
               name.contains('crypto') || name.contains('wallet')) {
      detected = 'Finance';
    } else if (name.contains('steam') || name.contains('epic') || name.contains('roblox') || 
               name.contains('pubg') || name.contains('game')) {
      detected = 'Games';
    } else if (name.contains('tokopedia') || name.contains('shopee') || name.contains('amazon') || 
               name.contains('lazada') || name.contains('shop')) {
      detected = 'Shopping';
    }

    if (detected != 'Other' && _selectedCategory != detected) {
      setState(() {
        _selectedCategory = detected;
      });
    }
  }

  void _saveAccount(AppLocalization loc) {
    if (_formKey.currentState!.validate()) {
      context.read<AccountProvider>().addAccount(
            serviceName: _serviceController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            category: _selectedCategory,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('save_success')),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  String _getLocalizedCategory(String cat, String langCode) {
    if (langCode == 'id') {
      switch (cat) {
        case 'Social Media': return 'Media Sosial';
        case 'Entertainment': return 'Hiburan';
        case 'Work/Email': return 'Kerja / Email';
        case 'Finance': return 'Keuangan';
        case 'Games': return 'Game';
        case 'Shopping': return 'Belanja';
        case 'Other': return 'Lainnya';
        default: return cat;
      }
    }
    return cat;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(loc.translate('add_new_account')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Keeping the aura background consistent
          const AuraBackground(selectedIndex: 0),
          
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                loc.translate('details'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _serviceController,
                label: loc.translate('service_name'),
                hint: loc.translate('service_hint'),
                icon: Icons.account_balance_wallet_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('fill_service') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: loc.translate('category'),
                  prefixIcon: Icon(_categories[_selectedCategory], color: const Color(0xFF6C63FF)),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
                  ),
                ),
                dropdownColor: Theme.of(context).cardTheme.color,
                items: _categories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(_categories[category], size: 20),
                        const SizedBox(width: 12),
                        Text(_getLocalizedCategory(category, settings.currentLanguage)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                label: loc.translate('username_email'),
                hint: 'e.g. john.doe@mail.com',
                icon: Icons.alternate_email_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('fill_username') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: loc.translate('password'),
                hint: settings.currentLanguage == 'id' ? 'Password kamu' : 'Your password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('fill_password') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: '${loc.translate('notes')} (${settings.currentLanguage == 'id' ? 'Opsional' : 'Optional'})',
                hint: settings.currentLanguage == 'id' ? 'Informasi Tambahan' : 'Additional Information',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _saveAccount(loc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    loc.translate('save_account'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
