import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Coordinator creates a club
  Future<void> createClub({
    required String name,
    required String description,
    required String ownerUid,
  }) async {
    await _db.collection('clubs').add({
      'name': name,
      'description': description,
      'ownerUid': ownerUid,
      'createdAt': Timestamp.now(),
    });
  }

  /// List all clubs
  Stream<List<Club>> getClubs() {
    return _db.collection('clubs').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Club.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Student joins club
  Future<void> joinClub(String clubId, String userUid) async {
    final docId = '${clubId}_$userUid';

    await _db.collection('club_members').doc(docId).set({
      'clubId': clubId,
      'userUid': userUid,
      'joinedAt': Timestamp.now(),
    });
  }

  /// Student leaves club
  Future<void> leaveClub(String clubId, String userUid) async {
    final docId = '${clubId}_$userUid';
    await _db.collection('club_members').doc(docId).delete();
  }

  /// Check if user is member
  Future<bool> isMember(String clubId, String userUid) async {
    final docId = '${clubId}_$userUid';
    final doc =
        await _db.collection('club_members').doc(docId).get();
    return doc.exists;
  }
  Stream<bool> isMemberStream(String clubId, String userUid) {
  final docId = '${clubId}_$userUid';

  return _db
      .collection('club_members')
      .doc(docId)
      .snapshots()
      .map((doc) => doc.exists);
}
  Stream<int> memberCountStream(String clubId) {
  return _db
      .collection('club_members')
      .where('clubId', isEqualTo: clubId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
Stream<List<String>> clubMemberUids(String clubId) {
  return _db
      .collection('club_members')
      .where('clubId', isEqualTo: clubId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((d) => d['userUid'] as String).toList(),
      );
}
Future<void> removeMember(String clubId, String userUid) async {
  final docId = '${clubId}_$userUid';

  await _db.collection('club_members').doc(docId).delete();
}
Stream<List<Club>> getClubsForCoordinator(String ownerUid) {
  return _db
      .collection('clubs')
      .where('ownerUid', isEqualTo: ownerUid)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Club.fromMap(doc.id, doc.data()))
            .toList(),
      );
}
Future<String> getClubName(String clubId) async {
  final doc = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .get();

  if (!doc.exists) return 'Unknown club';

  return doc['name'] as String;
}

}
