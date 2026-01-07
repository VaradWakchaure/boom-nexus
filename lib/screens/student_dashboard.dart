import 'package:flutter/material.dart';
import '../widgets/side_nav.dart';
import '../services/club_service.dart';
import '../models/club_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'club_details_page.dart';
import 'student_events_view.dart';
import '../theme/theme_controller.dart';
import 'profile_page.dart';



class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Row(
        children: [
          SideNav(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  onToggleTheme: () {
    themeController.toggleTheme();
  },
),

          const VerticalDivider(width: 1),
          Expanded(
  child: _selectedIndex == 0
      ? StudentEventsView()
      : _selectedIndex == 1
          ? ClubsView()
          : ProfilePage(),
),


        ],
      ),
    );
  }
}
class ClubsView extends StatelessWidget {
  ClubsView({super.key});

  final ClubService _clubService = ClubService();
  final FirestoreService _firestoreService = FirestoreService();
  final String userUid =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: _clubService.getClubs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (snapshot.hasError) {
  return Center(
    child: Text('Error: ${snapshot.error}'),
  );
}

final clubs = snapshot.data ?? [];

if (clubs.isEmpty) {
  return const Center(child: Text('No clubs yet'));
}

        return ListView.builder(
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];

            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(club.name),
                subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(club.description),

    const SizedBox(height: 4),

    FutureBuilder<String>(
      future: _firestoreService.getUserName(club.ownerUid),
      builder: (context, snapshot) {
        return Text(
          'Coordinator: ${snapshot.data ?? 'Loading...'}',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    ),

    const SizedBox(height: 4),

    StreamBuilder<int>(
      stream: _clubService.memberCountStream(club.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Text(
          '$count members',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    ),
  ],
),
onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubDetailsPage(club: club),
      ),
    );
  },

                trailing: StreamBuilder<bool>(
  stream: _clubService.isMemberStream(club.id, userUid),
  builder: (context, snapshot) {
    final isMember = snapshot.data ?? false;

                    return ElevatedButton(
                      onPressed: () {
                        isMember
                            ? _clubService.leaveClub(
                                club.id, userUid)
                            : _clubService.joinClub(
                                club.id, userUid);
                      },
                      child: Text(isMember ? 'Leave' : 'Join'),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
