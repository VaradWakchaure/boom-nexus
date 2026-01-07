import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class RoleSelectionPage extends StatelessWidget {
  final String uid;

  const RoleSelectionPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    Future<void> selectRole(String role) async {
      await firestoreService.updateUserRole(uid, role);

      // Temporary success screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role set to $role')),
      );
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select your role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose how you want to use the app',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => selectRole('student'),
              child: const Text('I am a Student'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => selectRole('coordinator'),
              child: const Text('I am a Coordinator'),
            ),
          ],
        ),
      ),
    );
  }
}
