import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KycService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 Future<void> submitKyc({
  required String idNumber,
  required String address,
  required String bankUpi,
  required String idProofUrl,
}) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final uid = user.uid;

  await _db.collection('users').doc(uid).set({
    'idNumber': idNumber,
    'address': address,
    'bankUpi': bankUpi,
    'idProofUrl': idProofUrl,
    'kycStatus': 'pending',
    'kycSubmittedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
}
