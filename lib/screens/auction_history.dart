import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'delivery_tracking.dart';

class AuctionHistoryPage extends StatelessWidget {
  const AuctionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Auction History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .where('sellerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['commodity']),
                  subtitle: Text("Status: ${data['status']}"),
                  trailing: Text("₹${data['highestBid'] ?? 0}"),
                  onTap: () {
                    /// 🚚 DELIVERY TRACKING
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryTrackingPage(
                          status: data['deliveryStatus'] ?? 'Processing',
                          location:
                              data['deliveryLocation'] ?? 'Warehouse',
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
