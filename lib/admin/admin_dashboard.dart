import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text("Pending KYC", style: TextStyle(fontSize: 18)),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('kycStatus', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    child: ListTile(
                      title: Text(doc['email']),
                      trailing: ElevatedButton(
                        child: const Text("Approve"),
                        onPressed: () {
                          doc.reference.update({'kycStatus': 'approved'});
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),
          const Text("Pending Auctions", style: TextStyle(fontSize: 18)),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    child: ListTile(
                      title: Text(doc['commodity']),
                      subtitle: Text("Base: ₹${doc['basePrice']}"),
                      trailing: ElevatedButton(
                        child: const Text("Approve"),
                        onPressed: () {
                          doc.reference.update({'status': 'approved'});
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
