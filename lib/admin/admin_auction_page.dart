import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/order_service.dart';

class AdminAuctionPage extends StatelessWidget {
  const AdminAuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Auctions")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['commodity']),
                  subtitle: Text("Status: ${data['status']}"),
                  trailing: ElevatedButton(
                    onPressed: data['status'] == 'ended'
                        ? null
                        : () async {
                            await OrderService()
                                .createOrderFromAuction(doc.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Auction closed & order created"),
                              ),
                            );
                          },
                    child: const Text("Close Auction"),
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
