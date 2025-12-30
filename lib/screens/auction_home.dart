import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_auction.dart';
import 'bid_page.dart';
import 'auction_history.dart';
import 'user_profile.dart';
import '../widgets/auction_timer.dart';


class AuctionHomePage extends StatelessWidget {
  const AuctionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Auction House'),
        actions: [
          /// 👤 USER PROFILE
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserProfilePage()),
              );
            },
          ),

          /// 📜 AUCTION HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AuctionHistoryPage()),
              );
            },
          ),


          /// 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      /// 🔐 KYC CHECK
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final kycStatus = userData['kycStatus'];

          /// ❌ KYC NOT APPROVED
          if (kycStatus != 'approved') {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 50, color: Colors.orange),
                  SizedBox(height: 10),
                  Text(
                    'KYC Verification Pending',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Please wait for admin approval',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          /// ✅ SHOW LIVE AUCTIONS
          return Stack(
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
              'No live auctions available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            final doc = auctions[index];
            final auction = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(auction['commodity']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Base Price: ₹${auction['basePrice']}"),
                    AuctionTimer(
                      endTime:
                          (auction['endTime'] as Timestamp).toDate(),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.gavel),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BidPage(
                        auctionId: doc.id,
                        currentBid: auction['highestBid'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ),
  ],
);

        },
      ),

      /// ➕ CREATE AUCTION
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Sell Commodity'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateAuctionPage()),
          );
        },
      ),
      
    );
  }
}
