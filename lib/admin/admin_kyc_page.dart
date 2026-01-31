import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_kyc_verify_page.dart';

class AdminKycPage extends StatelessWidget {
  const AdminKycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin • KYC Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('kycStatus', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending KYC requests"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final user = doc.data() as Map<String, dynamic>? ?? {};

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(user['name'] ?? 'No Name'),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: ElevatedButton(
                    child: const Text("Verify"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminKycVerifyPage(
                            userId: doc.id,
                            userData: user,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
