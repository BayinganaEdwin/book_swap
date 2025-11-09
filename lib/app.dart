import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/notification_listener.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        Widget home;
        
        if (auth.isSignedIn) {
          home = const BrowseScreen();
        } else if (auth.isSignedInButUnverified) {
          home = EmailVerificationScreen(email: auth.user?.email ?? '');
        } else {
          home = const AuthScreen();
        }

        return NotificationListenerWidget(
          child: MaterialApp(
            title: 'BookSwap',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF818CF8), // Lighter indigo for dark mode
                brightness: Brightness.dark,
                primary: const Color(0xFF818CF8),
                secondary: const Color(0xFFA78BFA),
                surface: const Color(0xFF1E293B),
                surfaceContainerHighest: const Color(0xFF334155),
                error: const Color(0xFFF87171),
                onPrimary: const Color(0xFF0F172A),
                onSecondary: const Color(0xFF0F172A),
                onSurface: const Color(0xFFF1F5F9),
                onSurfaceVariant: const Color(0xFFCBD5E1),
              ),
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
                displayLarge: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: const Color(0xFFF1F5F9),
                ),
                displayMedium: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: const Color(0xFFF1F5F9),
                ),
                displaySmall: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: const Color(0xFFF1F5F9),
                ),
                headlineMedium: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: const Color(0xFFF1F5F9),
                ),
                titleLarge: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF1F5F9),
                ),
                titleMedium: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF1F5F9),
                ),
                bodyLarge: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFF1F5F9),
                ),
                bodyMedium: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFCBD5E1),
                ),
                bodySmall: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF94A3B8),
                ),
                labelLarge: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.shade800,
                    width: 1,
                  ),
                ),
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
                ),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF818CF8),
                  foregroundColor: const Color(0xFF0F172A),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade600, width: 1.5),
                  foregroundColor: const Color(0xFFF1F5F9),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF818CF8),
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFF1F5F9),
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF1F5F9),
                ),
                iconTheme: const IconThemeData(
                  color: Color(0xFFF1F5F9),
                  size: 24,
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                elevation: 2,
                backgroundColor: const Color(0xFF818CF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                elevation: 8,
                backgroundColor: const Color(0xFF1E293B),
                selectedItemColor: const Color(0xFF818CF8),
                unselectedItemColor: const Color(0xFF64748B),
                selectedLabelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                type: BottomNavigationBarType.fixed,
              ),
              iconTheme: const IconThemeData(
                color: Color(0xFFF1F5F9),
                size: 24,
              ),
            ),
            home: home,
            routes: {
              '/home': (ctx) => const BrowseScreen(),
              '/auth': (ctx) => const AuthScreen(),
              '/verify': (ctx) => EmailVerificationScreen(
                email: auth.user?.email ?? '',
              ),
              '/notifications': (ctx) => const NotificationsScreen(),
            },
          ),
        );
      }),
    );
  }
}
