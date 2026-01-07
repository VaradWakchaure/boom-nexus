import 'package:flutter/material.dart';
import '../services/event_service.dart';

class EventParticipantsPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventParticipantsPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();

    return Scaffold(
      appBar: AppBar(title: Text(eventName)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: eventService.participantsStream(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final participants = snapshot.data ?? [];

          if (participants.isEmpty) {
            return const Center(child: Text('No participants yet'));
          }

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final user = participants[index];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user['name'] ?? 'No name'),
                subtitle: Text(user['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    eventService.removeParticipant(
                      eventId,
                      user['uid'],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
