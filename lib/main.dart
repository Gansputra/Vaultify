import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/hive_database.dart';
import 'providers/account_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'package:screen_protector/screen_protector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  
  // Aktifkan proteksi screenshot Android (FLAG_SECURE) secara permanen
  await ScreenProtector.preventScreenshotOn();
  
  runApp(const VaultifyApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class VaultifyApp extends StatelessWidget {
  const VaultifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Vaultify',
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
                primary: const Color(0xFF6C63FF),
                surface: const Color(0xFFF8F9FA),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              textTheme: GoogleFonts.outfitTextTheme(),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFFF8F9FA),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                iconTheme: const IconThemeData(color: Colors.black87),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withAlpha(20)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.dark,
                primary: const Color(0xFF6C63FF),
                secondary: const Color(0xFF00D2FF),
                surface: const Color(0xFF121212),
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0A0A),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF0A0A0A),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
