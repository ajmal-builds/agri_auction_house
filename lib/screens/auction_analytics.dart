import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionAnalytics extends StatelessWidget {
  const AuctionAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final total = snapshot.data!.docs.length;
        final active = snapshot.data!.docs
            .where((d) => d['status'] == 'approved')
            .length;

        return Card(
          child: ListTile(
            title: const Text("Auction Analytics"),
            subtitle: Text(
              "Total Auctions: $total\nLive Auctions: $active",
            ),
          ),
        );
      },
    );
  }
}
