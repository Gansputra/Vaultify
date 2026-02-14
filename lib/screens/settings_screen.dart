import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
            context,
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
            context,
            icon: Icons.timer_outlined,
            title: 'Auto Lock Timer',
            subtitle: 'Immediately',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildSettingsTile(
            context,
            icon: settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Mode Gelap',
            subtitle: settings.isDarkMode ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleTheme(val),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildSettingsTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup Data Lokal',
            subtitle: 'Ekspor atau Impor data akun',
            onTap: () => _showBackupOptions(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.delete_forever_rounded,
            title: 'Hapus Semua Data',
            subtitle: 'Zona Bahaya',
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
    final isDark = true; // Use fixed dark style for footer as it looks more premium, or adapt it
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

  void _showBackupOptions(BuildContext context) {
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
              title: Text('Ekspor Data (Backup)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text('Simpan akun sebagai file JSON', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150))),
              onTap: () async {
                // Tutup BottomSheet dulu
                Navigator.pop(context);
                
                final result = await accountProvider.exportBackup();
                
                // Cek hasil export
                if (!context.mounted) return;
                
                if (result == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup Berhasil! Data sudah diekspor.')),
                  );
                } else if (result == 'empty') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belum ada data untuk di-backup.')),
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
              title: Text('Impor Data (Restore)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text('Pulihkan akun dari file JSON', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150))),
              onTap: () async {
                // Tutup BottomSheet dulu
                Navigator.pop(context);
                
                final result = await accountProvider.importBackup();
                
                // Cek hasil import
                if (!context.mounted) return;
                
                if (result.toLowerCase().contains('successfully')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                } else if (result.contains('No new accounts')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impor Selesai. Tidak ada data baru.')),
                  );
                } else if (result != 'cancelled') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text('Hapus Semua Data?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text('Tindakan ini tidak dapat dibatalkan. Semua akun tersimpan akan hilang.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(180))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).disabledColor)),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<AccountProvider>();
              await provider.clearAllAccounts();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data berhasil dihapus!')),
                );
              }
            },
            child: const Text('Hapus Sekarang', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
