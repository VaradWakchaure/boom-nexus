import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import 'event_participants_page.dart';

class CoordinatorEventsView extends StatelessWidget {
  CoordinatorEventsView({super.key});

  final EventService _eventService = EventService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    print('>>> CoordinatorEventsView BUILD CALLED <<<');
    return StreamBuilder<List<Event>>(
      stream: _eventService.getEventsByCoordinator(uid),
      builder: (context, snapshot) {
        print('EVENTS SNAPSHOT: ${snapshot.data}');
print('COORD UID: $uid');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
  return const Center(
    child: Text(
      'No events created yet',
      style: TextStyle(fontSize: 18),
    ),
  );
}


        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];

            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(event.name),
                subtitle: Text(event.description),
                trailing: const Icon(Icons.people),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventParticipantsPage(
                        eventId: event.id,
                        eventName: event.name,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
