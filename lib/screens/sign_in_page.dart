import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';
import 'role_selection_page.dart';
import 'student_dashboard.dart';
import 'coordinator_dashboard.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App title
                  Text(
                    'Campus Connect',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Connect with clubs & events on campus',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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

                        if (!context.mounted) return;

                        if (savedUser.role == null) {
                          Navigator.pushReplacement(
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
                        } else {
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

                  const SizedBox(height: 16),

                  Text(
                    'Powered by Google Sign-In',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
