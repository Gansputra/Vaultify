import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../widgets/custom_text_field.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
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

  void _saveAccount() {
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
          content: const Text('Akun Berhasil Di Save!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Akun Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Akun',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _serviceController,
                label: 'Nama Layanan',
                hint: 'e.g. Google, Netflix, Spotify',
                icon: Icons.account_balance_wallet_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Isi Nama Layanan Dulu Bro' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
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
                        Text(category),
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
                label: 'Username / Email',
                hint: 'e.g. john.doe@mail.com',
                icon: Icons.alternate_email_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Isi Username Dulu Bro' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Your password',
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
                    value == null || value.isEmpty ? 'Isi Password Dulu Bro' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: 'Catatan (Optional)',
                hint: 'Informasi Tambahan',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Save Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
