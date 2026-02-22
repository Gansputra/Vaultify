import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insight Brankas'),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          final accounts = provider.accounts;
          
          if (accounts.isEmpty) {
            return const Center(
              child: Text('Belum ada data untuk dianalisis King!'),
            );
          }

          // Calculate stats
          final Map<String, int> stats = {};
          for (var account in accounts) {
            final cat = account.category ?? 'Other';
            stats[cat] = (stats[cat] ?? 0) + 1;
          }

          final sortedStats = stats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, accounts.length),
                const SizedBox(height: 32),
                Text(
                  'Distribusi Kategori',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...sortedStats.map((entry) => _buildStatItem(
                  context, 
                  entry.key, 
                  entry.value, 
                  accounts.length
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Akun Tersimpan',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$total Akun',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Keamanan Terenkripsi',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildStatItem(BuildContext context, String category, int count, int total) {
    final percentage = count / total;
    final color = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '$count Akun (${(percentage * 100).toStringAsFixed(0)}%)',
                style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCirc,
                height: 10,
                width: MediaQuery.of(context).size.width * 0.8 * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ).animate().shimmer(delay: 400.ms, duration: 1.seconds),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    return switch (category) {
      'Social Media' => const Color(0xFF1877F2),
      'Entertainment' => const Color(0xFFE50914),
      'Work/Email' => const Color(0xFF34A853),
      'Finance' => const Color(0xFFFBBC05),
      'Games' => const Color(0xFF6C63FF),
      'Shopping' => const Color(0xFFFF9900),
      _ => const Color(0xFF9E9E9E),
    };
  }
}
