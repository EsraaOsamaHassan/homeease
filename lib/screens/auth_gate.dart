import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeease/screens/role_selection_screen.dart';

import '../theme.dart';
import 'auth_screen.dart';

/// بيعرض شاشة الدخول لو مفيش مستخدم، وإلا بيعرض التطبيق.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    // required this.signedIn,
    required this.customerHome,
    required this.providerHome,
  });
  // final Widget signedIn;
  final Widget customerHome;
  final Widget providerHome;

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
        if (!snap.hasData) return const AuthScreen();
        // return const AuthScreen();
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(snap.data!.uid)
              .snapshots(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.terracotta),
                ),
              );
            }

            final role = roleSnap.data?.data()?['role'] as String?;
            if (role == null) {
              return const RoleSelectionScreen(); // أول مرة → يختار
            }

            return role == 'provider' ? providerHome : customerHome;
          },
        );
      },
    );
  }
}
