import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BidPage extends StatefulWidget {
  final String auctionId;

  const BidPage({
    super.key,
    required this.auctionId,
  });

  @override
  State<BidPage> createState() => _BidPageState();
}

class _BidPageState extends State<BidPage>
    with SingleTickerProviderStateMixin {

  final bidController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> placeBid(int currentBid) async {
    final newBid = int.tryParse(bidController.text);

    if (newBid == null || newBid <= currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid must be higher")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final docRef =
        FirebaseFirestore.instance.collection('auctions').doc(widget.auctionId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final latestBid = snapshot['highestBid'];

      if (newBid > latestBid) {
        transaction.update(docRef, {
          'highestBid': newBid,
          'highestBidderId': uid,
        });

        transaction.set(
          docRef.collection('bids').doc(),
          {
            'bidderId': uid,
            'amount': newBid,
            'time': FieldValue.serverTimestamp(),
          },
        );
      } else {
        throw Exception("Someone already placed higher bid");
      }
    });

    bidController.clear();
  }

  void showBidHistory() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('auctions')
              .doc(widget.auctionId)
              .collection('bids')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final bids = snapshot.data!.docs;

            return ListView(
              children: bids.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text("₹${data['amount']}"),
                  subtitle: Text("Bidder: ${data['bidderId']}"),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Bidding"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: showBidHistory,
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .doc(widget.auctionId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final auction =
              snapshot.data!.data() as Map<String, dynamic>;

          final currentBid = auction['highestBid'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    "₹$currentBid",
                    key: ValueKey(currentBid),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: bidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Enter your bid",
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => placeBid(currentBid),
                  child: const Text("Place Bid"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
