import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class AdminKycVerifyPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const AdminKycVerifyPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  Future<void> approve(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'kycStatus': 'approved'});

    await NotificationService().send(
      userId: userId,
      title: "KYC Approved",
      message: "Your KYC has been approved",
      type: "kyc",
    );

    Navigator.pop(context);
  }

  Future<void> reject(BuildContext context) async {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject KYC"),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: "Reason"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'kycStatus': 'rejected',
                'kycRejectReason': reasonCtrl.text,
              });

              await NotificationService().send(
                userId: userId,
                title: "KYC Rejected",
                message: reasonCtrl.text,
                type: "kyc",
              );

              Navigator.pop(context); // dialog
              Navigator.pop(context); // page
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? idProofUrl = userData['idProofUrl'];

    return Scaffold(
      appBar: AppBar(title: const Text("Verify KYC")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Name: ${userData['name'] ?? '-'}"),
            Text("Email: ${userData['email'] ?? '-'}"),
            Text("Address: ${userData['address'] ?? '-'}"),
            Text("ID Number: ${userData['idNumber'] ?? '-'}"),

            const SizedBox(height: 20),

            /// 🖼️ ID PROOF IMAGE VIEWER
            const Text(
              "ID Proof Image",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (idProofUrl != null && idProofUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(url: idProofUrl),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    idProofUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text("Failed to load image"),
                  ),
                ),
              )
            else
              const Text(
                "No ID proof uploaded",
                style: TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 30),

            /// ✅ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => approve(context),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => reject(context),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔍 FULL SCREEN IMAGE VIEW
class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}
