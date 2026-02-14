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
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      context.read<AccountProvider>().addAccount(
            serviceName: _serviceController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
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
