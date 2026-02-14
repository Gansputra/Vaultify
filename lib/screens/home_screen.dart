import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../widgets/account_card.dart';
import 'add_account_screen.dart';
import 'settings_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AccountProvider>().loadAccounts();
        _showSecurityJoke();
      }
    });
  }

  void _showSecurityJoke() {
    final jokes = [
      'Gak usah nyoba SS bro, percuma bakal item pekat! 😎',
      'Tenang bro, rahasia lu aman di brankas anti-screenshot ini. 🛡️',
      'Eits! Vaultify lagi dalam mode "Sangat Rahasia". SS diblokir! 🔐',
      'Lagi nyari celah ya? Safe and secure bro, santai aja. 🔥',
      'Security tip: Jangan pamer password ke mantan ya! 😜',
    ];
    
    final randomJoke = jokes[Random().nextInt(jokes.length)];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.security_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(randomJoke, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaultify'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAccountScreen()),
          );
        },
        label: const Text('Tambah Akun'),
        icon: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 500.ms),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<AccountProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari Akun...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6C63FF)),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          Expanded(
            child: Consumer<AccountProvider>(
              builder: (context, provider, child) {
                if (provider.accounts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 100,
                          color: Theme.of(context).disabledColor.withAlpha(50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum Ada Akun Tersimpan',
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.accounts.length,
                  itemBuilder: (context, index) {
                    final account = provider.accounts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AccountCard(account: account),
                    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
