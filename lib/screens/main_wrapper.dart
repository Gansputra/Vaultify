import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'password_generator_screen.dart';
import '../providers/settings_provider.dart';
import '../services/localization_service.dart';
import 'dart:ui';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final loc = AppLocalization(settings.currentLanguage);
    
    final List<Widget> screens = [
      const HomeScreen(),
      const PasswordGeneratorScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];
    
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe to keep it clean
            children: screens,
          ),
          
          // Modern Floating Navbar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withAlpha(180),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withAlpha(20),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(0, Icons.grid_view_rounded, loc.translate('nav_vault')),
                      _buildNavItem(1, Icons.vpn_key_rounded, loc.translate('nav_keys')),
                      _buildNavItem(2, Icons.analytics_rounded, loc.translate('nav_stats')),
                      _buildNavItem(3, Icons.settings_rounded, loc.translate('nav_setup')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10, 
          vertical: 10
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.withAlpha(150),
              size: 22,
            ).animate(target: isSelected ? 1 : 0)
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 300.ms, curve: Curves.easeOutBack)
             .tint(color: isSelected ? primaryColor : Colors.grey, duration: 300.ms),
            
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ).animate()
               .fadeIn(duration: 200.ms)
               .slideX(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
            ],
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
     .shimmer(
       delay: 400.ms, 
       duration: 1.5.seconds, 
       color: primaryColor.withAlpha(20),
     );
  }
}
