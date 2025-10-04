import 'package:euro_rens/core/constants/colors.dart';
import 'package:euro_rens/core/constants/app_theme.dart';
import 'package:euro_rens/core/constants/strings.dart';
import 'package:euro_rens/core/services/navigation_service.dart';
import 'package:euro_rens/core/services/notification_service.dart';
import 'package:euro_rens/presentation/auth/login_page.dart';
import 'package:euro_rens/presentation/auth/register_page.dart';
import 'package:euro_rens/presentation/auth/forgot_password.dart';
import 'package:euro_rens/presentation/home/home_page.dart';
import 'package:euro_rens/presentation/onboarding/onboarding_page.dart';
import 'package:euro_rens/presentation/onboarding/onboarding_view_model.dart';
import 'package:euro_rens/presentation/admin/admin_dashboard_page.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'data/models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final onboardingVM = OnboardingViewModel();
  final seenOnboarding = await onboardingVM.hasSeenOnboarding();

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NotificationService.messengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Decide initial screen
      home: seenOnboarding
          ? StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const LoginPage();
                }

                final firebaseUser = snapshot.data!;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(firebaseUser.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      );
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const HomePage();
                    }

                    final appUser = AppUser.fromMap(
                      userSnapshot.data!.data() as Map<String, dynamic>,
                      userSnapshot.data!.id,
                    );

                    if (appUser.isAdmin) {
                      return const AdminDashboardPage();
                    } else {
                      return const HomePage();
                    }
                  },
                );
              },
            )
          : const OnboardingPage(),

      // Routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
