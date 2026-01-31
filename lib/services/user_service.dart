import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<String> getUserRole() async {
    final data = await getCurrentUserData();
    return data?['role'] ?? 'user';
  }
}
