import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final theme = Theme.of(context);

    return FutureBuilder<AppUser>(
      future: _firestoreService.getUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final appUser = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    appUser.name[0].toUpperCase(),
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _infoTile('Name', appUser.name),
              _infoTile('Email', appUser.email),
              _infoTile('Role', appUser.role ?? 'Not set'),

              const Spacer(),

              // Sign out
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (_) => false);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
