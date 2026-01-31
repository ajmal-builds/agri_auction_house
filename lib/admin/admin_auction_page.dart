import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_verify_auction_page.dart';

class AdminAuctionPage extends StatelessWidget {
  const AdminAuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Auctions")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final auctions = snapshot.data!.docs;

          if (auctions.isEmpty) {
            return const Center(child: Text("No pending auctions"));
          }

          return ListView.builder(
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              final doc = auctions[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(data['commodityName'] ?? 'Unknown'),
                  subtitle:
                      Text("Base Price: ₹${data['basePrice'] ?? 0}"),
                  trailing: ElevatedButton(
                    child: const Text("Verify"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminVerifyAuctionPage(
                            auctionId: doc.id,
                            auctionData: data,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
