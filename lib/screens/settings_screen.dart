import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../services/localization_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader(loc.translate('settings_security')),
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: loc.translate('settings_biometric'),
            subtitle: loc.languageCode == 'id' ? 'Sidik Jari / Biometrik' : 'Fingerprint / Face ID',
            trailing: Switch(
              value: settings.biometricEnabled,
              onChanged: (val) => settings.toggleBiometric(val),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('settings_appearance')),
          _buildSettingsTile(
            context,
            icon: settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: loc.translate('settings_dark_mode'),
            subtitle: settings.isDarkMode 
                ? (loc.languageCode == 'id' ? 'Mode Gelap Aktif' : 'Dark Mode Enabled')
                : (loc.languageCode == 'id' ? 'Mode Terang Aktif' : 'Light Mode Enabled'),
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleTheme(val),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            title: loc.translate('settings_language'),
            subtitle: settings.currentLanguage == 'id' ? 'Bahasa Indonesia' : 'English',
            onTap: () => _showLanguagePicker(context, settings, loc),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                settings.currentLanguage == 'id' ? '🇮🇩' : '🇺🇸',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.languageCode == 'id' ? 'DATA' : 'DATA'),
          _buildSettingsTile(
            context,
            icon: Icons.backup_outlined,
            title: loc.languageCode == 'id' ? 'Backup Data Lokal' : 'Local Data Backup',
            subtitle: loc.languageCode == 'id' ? 'Ekspor atau Impor data akun' : 'Export or Import account data',
            onTap: () => _showBackupOptions(context, loc),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.delete_forever_rounded,
            title: loc.languageCode == 'id' ? 'Hapus Semua Data' : 'Clear All Data',
            subtitle: loc.languageCode == 'id' ? 'Zona Bahaya' : 'Danger Zone',
            iconColor: Colors.redAccent,
            onTap: () => _showDeleteAllDialog(context, loc),
          ),
          const SizedBox(height: 40),
          _buildAuthorFooter(loc),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings, AppLocalization loc) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('change_lang_title'),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageItem(context, 'Bahasa Indonesia', 'id', '🇮🇩', settings),
            const SizedBox(height: 8),
            _buildLanguageItem(context, 'English', 'en', '🇺🇸', settings),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, String code, String flag, SettingsProvider settings) {
    final isSelected = settings.currentLanguage == code;
    return InkWell(
      onTap: () {
        settings.setLanguage(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorFooter(AppLocalization loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withAlpha(15),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Gansputra',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.languageCode == 'id' ? 'Dibuat dengan Sepenuh Hati' : 'Crafted with Passion',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSocialLink(
                  label: 'GitHub',
                  url: 'https://github.com/Gansputra/',
                  icon: Icons.code_rounded,
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialLink(
                  label: 'Instagram',
                  url: 'https://instagram.com/gans.putra_',
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xFFE4405F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink({
    required String label,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.white.withAlpha(5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withAlpha(10)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).cardTheme.color,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF6C63FF)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(180), fontSize: 13)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Theme.of(context).disabledColor),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showBackupOptions(BuildContext context, AppLocalization loc) {
    final accountProvider = context.read<AccountProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Backup & Restore',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_rounded, color: Colors.blue),
              ),
              title: Text(loc.languageCode == 'id' ? 'Ekspor Data (Backup)' : 'Export Data (Backup)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text(loc.languageCode == 'id' ? 'Simpan akun sebagai file JSON' : 'Save accounts as JSON file', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150))),
              onTap: () async {
                // Tutup BottomSheet dulu
                Navigator.pop(context);
                
                final result = await accountProvider.exportBackup();
                
                // Cek hasil export
                if (!context.mounted) return;
                
                if (result == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.languageCode == 'id' ? 'Backup Berhasil!' : 'Backup Successful!')),
                  );
                } else if (result == 'empty') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('stats_no_data'))),
                  );
                } else if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download_rounded, color: Colors.green),
              ),
              title: Text(loc.languageCode == 'id' ? 'Impor Data (Restore)' : 'Import Data (Restore)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text(loc.languageCode == 'id' ? 'Pulihkan akun dari file JSON' : 'Restore accounts from JSON file', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150))),
              onTap: () async {
                // Tutup BottomSheet dulu
                Navigator.pop(context);
                
                final result = await accountProvider.importBackup();
                
                // Cek hasil import
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  void _showDeleteAllDialog(BuildContext context, AppLocalization loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(loc.translate('delete_title'), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text(
          loc.languageCode == 'id' 
            ? 'Tindakan ini tidak dapat dibatalkan. Semua akun tersimpan akan hilang.' 
            : 'This action cannot be undone. All saved accounts will be lost.', 
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(180))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel'), style: TextStyle(color: Theme.of(context).disabledColor)),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<AccountProvider>();
              await provider.clearAllAccounts();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.languageCode == 'id' ? 'Semua data berhasil dihapus!' : 'All data cleared successfully!')),
                );
              }
            },
            child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
