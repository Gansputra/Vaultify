import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Unlock',
            subtitle: 'Fingerprint / Face ID',
            trailing: Switch(
              value: settings.biometricEnabled,
              onChanged: (val) => settings.toggleBiometric(val),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.timer_outlined,
            title: 'Auto Lock Timer',
            subtitle: 'Immediately',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildSettingsTile(
            icon: settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Dark Mode',
            subtitle: settings.isDarkMode ? 'Dark side is active' : 'Light side is active',
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleTheme(val),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildSettingsTile(
            icon: Icons.backup_outlined,
            title: 'Backup Data Lokal',
            subtitle: 'Coming soon',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Hapus Semua Data',
            subtitle: 'Danger zone',
            iconColor: Colors.redAccent,
            onTap: () => _showDeleteAllDialog(context),
          ),
          const SizedBox(height: 40),
          _buildAuthorFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAuthorFooter() {
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
            'Crafted with Passion',
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF6C63FF)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Semua akun tersimpan akan hilang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              // Implementation in AccountProvider
              Navigator.pop(context);
            },
            child: const Text('Hapus Sekarang', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
