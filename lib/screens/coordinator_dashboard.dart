import 'package:flutter/material.dart';
import '../widgets/side_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/club_service.dart';
import '../models/club_model.dart';
import 'club_details_page.dart';
import 'create_club_page.dart';
import 'create_event_page.dart';
import 'coordinator_events_view.dart';
import '../theme/theme_controller.dart';
import 'profile_page.dart';




class CoordinatorDashboard extends StatefulWidget {
  const CoordinatorDashboard({super.key});

  @override
  State<CoordinatorDashboard> createState() =>
      _CoordinatorDashboardState();
}

class _CoordinatorDashboardState
    extends State<CoordinatorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Coordinator Dashboard')),
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
      ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateEventPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: CoordinatorEventsView(), // ✅ THIS WAS MISSING
            ),
          ],
        )
      : _selectedIndex == 1
          ? CoordinatorClubsView()
          : ProfilePage(),
),



        ],
      ),
    );
  }
}
class CoordinatorClubsView extends StatelessWidget {
  CoordinatorClubsView({super.key});

  final ClubService _clubService = ClubService();
  final String currentUid =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: _clubService.getClubsForCoordinator(currentUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final clubs = snapshot.data ?? [];

        if (clubs.isEmpty) {
          return const Center(
            child: Text('You have not created any clubs'),
          );
        }

        return Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Create Club'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateClubPage(),
              ),
            );
          },
        ),
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(club.name),
              subtitle: Text(club.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ClubDetailsPage(club: club),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  ],
);

      },
    );
  }
}

