import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';
import 'role_selection_page.dart';
import 'student_dashboard.dart';
import 'coordinator_dashboard.dart';

class AuthTestPage extends StatelessWidget {
  AuthTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in with Google'),
          onPressed: () async {
            final firebaseUser =
                await authService.signInWithGoogle();

            if (firebaseUser == null) return;

            final appUser = AppUser(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'No Name',
              email: firebaseUser.email ?? '',
              role: null,
            );

            final savedUser =
                await firestoreService.createOrGetUser(appUser);

            if (savedUser.role == null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RoleSelectionPage(uid: savedUser.uid),
                ),
              );
            } else if (savedUser.role == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentDashboard(),
                ),
              );
            } else if (savedUser.role == 'coordinator') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CoordinatorDashboard(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
