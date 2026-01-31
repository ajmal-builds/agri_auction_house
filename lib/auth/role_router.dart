import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_dashboard.dart';
import '../screens/auction_home.dart';
import 'login.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 🔄 Waiting for auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginPage();
        }

        final user = authSnapshot.data!;

        // 🔐 Logged in → check role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
              return const LoginPage();
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'] ?? 'user';

            return role == 'admin'
                ? const AdminDashboard()
                : const AuctionHomePage();
          },
        );
      },
    );
  }
}
