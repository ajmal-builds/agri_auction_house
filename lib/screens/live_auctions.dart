import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bid_page.dart';

class LiveAuctionsPage extends StatelessWidget {
  const LiveAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Auctions")),
      body: Stack(
  children: [
    Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/spices_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    ),
    Container(color: Colors.black.withOpacity(0.3)),

    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('auctions')
          .where('status', isEqualTo: 'live')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final auctions = snapshot.data!.docs;

        if (auctions.isEmpty) {
          return const Center(
            child: Text(
              "No live auctions",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            final data = auctions[index];
            final auction = data.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(auction['commodity']),
                subtitle: Text("Highest Bid: ₹${auction['highestBid']}"),
                trailing: ElevatedButton(
                  child: const Text("Bid"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BidPage(
                          auctionId: data.id,
                          currentBid: auction['highestBid'],
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
  ],
),

    );
  }
}
