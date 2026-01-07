import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new event
  Future<void> createEvent({
    required String clubId,
    required String name,
    required String description,
    required DateTime dateTime,
    required String createdBy,
  }) async {
    await _db.collection('events').add({
      'clubId': clubId,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'createdBy': createdBy,
    });
  }

  /// Students see all events
  Stream<List<Event>> getAllEvents() {
    return _db
        .collection('events')
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Coordinator sees their events
  Stream<List<Event>> getEventsByCoordinator(String uid) {
    return _db
        .collection('events')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Register student (NEW MODEL)
  Future<void> registerForEvent(String eventId, String userUid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userUid)
        .set({
      'userUid': userUid,
      'joinedAt': Timestamp.now(),
    });
  }

  /// Unregister student
  Future<void> unregisterFromEvent(String eventId, String userUid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userUid)
        .delete();
  }

  /// Check if student is registered
  Stream<bool> isRegisteredStream(String eventId, String userUid) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Coordinator: see participants
  Stream<List<Map<String, dynamic>>> participantsStream(String eventId) {
  return _db
      .collection('events')
      .doc(eventId)
      .collection('participants')
      .snapshots()
      .asyncMap((snapshot) async {
        final users = <Map<String, dynamic>>[];

        for (final doc in snapshot.docs) {
          final userSnap =
              await _db.collection('users').doc(doc.id).get();

          if (userSnap.exists) {
            users.add(userSnap.data()!);
          }
        }

        return users;
      });
}


  /// Coordinator: remove participant
  Future<void> removeParticipant(String eventId, String userUid) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userUid)
        .delete();
  }
}

