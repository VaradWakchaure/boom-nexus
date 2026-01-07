import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create user only if not exists
  Future<AppUser> createOrGetUser(AppUser user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(user.toMap());
      return user;
    } else {
      return AppUser.fromMap(doc.id, doc.data()!);
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
  final docRef = _db.collection('users').doc(uid);
  final doc = await docRef.get();

  if (doc.exists && doc.data()?['role'] == null) {
    await docRef.update({'role': role});
  }
}
Future<String> getUserName(String uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  return doc.data()?['name'] ?? 'Unknown';
}
Future<AppUser> getUser(String uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (!doc.exists) {
    throw Exception('User not found');
  }

  return AppUser.fromMap(doc.id, doc.data()!);
}





}
