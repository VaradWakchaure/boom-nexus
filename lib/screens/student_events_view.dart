import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import '../services/club_service.dart';

class StudentEventsView extends StatelessWidget {
  StudentEventsView({super.key});

  final EventService _eventService = EventService();
  final ClubService _clubService = ClubService();
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: _eventService.getAllEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text('No events available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];

            return _EventCard(
              event: event,
              userUid: userUid,
              eventService: _eventService,
              clubService: _clubService,
            );
          },
        );
      },
    );
  }
}
class _EventCard extends StatelessWidget {
  final Event event;
  final String userUid;
  final EventService eventService;
  final ClubService clubService;

  const _EventCard({
    required this.event,
    required this.userUid,
    required this.eventService,
    required this.clubService,
  });

  @override
  Widget build(BuildContext context) {
    final date = event.dateTime;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Date chip + Club chip
            Row(
              children: [
                _DateChip(date: date),
                const SizedBox(width: 8),
                FutureBuilder<String>(
                  future: clubService.getClubName(event.clubId),
                  builder: (context, snapshot) {
                    return _MetaChip(
                      icon: Icons.groups,
                      label: snapshot.data ?? 'Loading club…',
                    );
                  },
                ),
                const Spacer(),
                Icon(Icons.event, color: theme.colorScheme.primary),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              event.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 14),

            // Action row
            Align(
              alignment: Alignment.centerRight,
              child: StreamBuilder<bool>(
                stream: eventService.isRegisteredStream(
                  event.id,
                  userUid,
                ),
                builder: (context, snap) {
                  final isRegistered = snap.data ?? false;

                  return ElevatedButton(
                    onPressed: () {
                      isRegistered
                          ? eventService.unregisterFromEvent(
                              event.id, userUid)
                          : eventService.registerForEvent(
                              event.id, userUid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.primary,
                      foregroundColor: isRegistered
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      isRegistered ? 'Registered' : 'Register',
                    ),
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
class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '${_month(date.month)} ${date.day}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

