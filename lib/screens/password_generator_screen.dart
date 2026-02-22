import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/localization_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _passwordLength = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+=-[]{}|;:,.<>?';

    String allowedChars = '';
    if (_includeUppercase) allowedChars += upperCase;
    if (_includeLowercase) allowedChars += lowerCase;
    if (_includeNumbers) allowedChars += numbers;
    if (_includeSymbols) allowedChars += symbols;

    if (allowedChars.isEmpty) {
      final loc = AppLocalization(context.read<SettingsProvider>().currentLanguage);
      setState(() => _generatedPassword = loc.languageCode == 'id' ? 'Pilih salah satu dulu King!' : 'Select at least one option!');
      return;
    }

    final Random random = Random();
    String password = '';
    for (int i = 0; i < _passwordLength.toInt(); i++) {
      password += allowedChars[random.nextInt(allowedChars.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  double _calculateStrength() {
    if (_generatedPassword.isEmpty || _generatedPassword.contains('!')) return 0.0;
    
    double score = 0;
    if (_passwordLength > 8) score += 0.2;
    if (_passwordLength > 12) score += 0.2;
    if (_includeUppercase && _includeLowercase) score += 0.2;
    if (_includeNumbers) score += 0.2;
    if (_includeSymbols) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.4) return Colors.redAccent;
    if (strength <= 0.6) return Colors.orangeAccent;
    if (strength <= 0.8) return Colors.blueAccent;
    return Colors.greenAccent;
  }

  String _getStrengthText(double strength, AppLocalization loc) {
    if (strength <= 0.4) return loc.translate('gen_strength_weak');
    if (strength <= 0.6) return loc.translate('gen_strength_fair');
    if (strength <= 0.8) return loc.translate('gen_strength_strong');
    return loc.translate('gen_strength_god');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);
    final strength = _calculateStrength();
    final strengthColor = _getStrengthColor(strength);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(loc.translate('gen_title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
        child: Column(
          children: [
            // Generated Password Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SelectableText(
                    _generatedPassword,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(key: ValueKey(_generatedPassword)).fadeIn().scale(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStrengthText(strength, loc),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: strengthColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: strengthColor.withAlpha(40),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: 6,
                                  width: (MediaQuery.of(context).size.width - 96) * strength,
                                  decoration: BoxDecoration(
                                    color: strengthColor,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: strengthColor.withAlpha(100),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedPassword));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.translate('gen_copy_success')),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Controls
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.translate('gen_length'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _passwordLength.toInt().toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _passwordLength,
                    min: 6,
                    max: 32,
                    divisions: 26,
                    label: _passwordLength.round().toString(),
                    onChanged: (value) {
                      setState(() => _passwordLength = value);
                      _generatePassword();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOption(loc.translate('gen_uppercase'), _includeUppercase, (v) => setState(() { _includeUppercase = v; _generatePassword(); })),
                  _buildOption(loc.translate('gen_lowercase'), _includeLowercase, (v) => setState(() { _includeLowercase = v; _generatePassword(); })),
                  _buildOption(loc.translate('gen_numbers'), _includeNumbers, (v) => setState(() { _includeNumbers = v; _generatePassword(); })),
                  _buildOption(loc.translate('gen_symbols'), _includeSymbols, (v) => setState(() { _includeSymbols = v; _generatePassword(); })),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generatePassword,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  loc.translate('gen_refresh'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate().shimmer(delay: 2.seconds, duration: 1500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
