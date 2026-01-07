import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../models/app_user.dart';
import '../services/club_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubDetailsPage extends StatelessWidget {
  final Club club;

  ClubDetailsPage({super.key, required this.club});

  final ClubService _clubService = ClubService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final String currentUid =
        FirebaseAuth.instance.currentUser!.uid;

    final bool isCoordinator = currentUid == club.ownerUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(club.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Club description
            Text(
              club.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 12),

            /// Coordinator name
            FutureBuilder<String>(
              future: _firestoreService.getUserName(club.ownerUid),
              builder: (context, snapshot) {
                return Text(
                  'Coordinator: ${snapshot.data ?? 'Loading...'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              'Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            /// Member list
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _clubService.clubMemberUids(club.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final uids = snapshot.data ?? [];

                  if (uids.isEmpty) {
                    return const Center(
                        child: Text('No members yet'));
                  }

                  return ListView.builder(
                    itemCount: uids.length,
                    itemBuilder: (context, index) {
                      final uid = uids[index];

                      return FutureBuilder<AppUser>(
                        future: _firestoreService.getUser(uid),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData) {
                            return const SizedBox();
                          }

                          final user = userSnap.data!;
                          final bool isSelf = uid == currentUid;

                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            trailing: isCoordinator && !isSelf
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove member',
                                    onPressed: () async {
                                      await _clubService
                                          .removeMember(
                                              club.id, uid);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Member removed'),
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
