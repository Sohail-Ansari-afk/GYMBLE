import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/biometric_service.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/checkin/checkin_screen.dart';
import 'features/checkin/dual_checkin_screen.dart';
import 'features/plans/plans_screen.dart';
import 'features/payments/payments_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/subscription/subscription_screen.dart';

// Provide BiometricService globally
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the auth repository when the app starts
    Future.microtask(() => ref.read(authRepositoryProvider).initialize());
  }

  @override
  Widget build(BuildContext context) {
    // Set up text theme with Inter font
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(),
      bodyMedium: GoogleFonts.inter(),
      bodySmall: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
    );

    // Watch auth status to determine initial route
    final authStatus = ref.watch(authStatusProvider);

    // Use CupertinoApp for iOS-style navigation and components
    return CupertinoApp(
      title: 'Gymble',
      theme: CupertinoThemeData(
        primaryColor: const Color(0xFFF8BBD0), // Frost pink color
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
      ),
      home: authStatus == AuthStatus.authenticated 
          ? const HomePage() 
          : const LoginScreen(),
      routes: {
        '/subscription': (context) => const SubscriptionScreen(),
        '/plans': (context) => const PlansScreen(),
      },
      // For Material components that we still need to use
      builder: (context, child) {
        return MediaQuery(
          // Support Dynamic Type with textScaleFactor
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Material(type: MaterialType.transparency, child: child!),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Dashboard')),
                  child: SafeArea(child: DashboardScreen()),
                );
              case 1:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Check-in')),
                  child: SafeArea(child: DualCheckinScreen()),
                );
              case 2:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Plans')),
                  child: SafeArea(child: PlansScreen()),
                );
              case 3:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Payments')),
                  child: SafeArea(child: PaymentsScreen()),
                );
              case 4:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Profile')),
                  child: SafeArea(child: ProfileScreen()),
                );
              default:
                return const CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(middle: Text('Dashboard')),
                  child: SafeArea(child: DashboardScreen()),
                );
            }
          },
        );
      },
    );
  }
}