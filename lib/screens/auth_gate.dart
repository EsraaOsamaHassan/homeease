import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'auth_screen.dart';

/// بيعرض شاشة الدخول لو مفيش مستخدم، وإلا بيعرض التطبيق.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.signedIn});
  final Widget signedIn;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
          );
        }
        if (snap.hasData) return signedIn;
        return const AuthScreen();
      },
    );
  }
}