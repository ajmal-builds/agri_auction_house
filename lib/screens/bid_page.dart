import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BidPage extends StatefulWidget {
  final String auctionId;
  final int currentBid;

  const BidPage({
    super.key,
    required this.auctionId,
    required this.currentBid,
  });

  @override
  State<BidPage> createState() => _BidPageState();
}

class _BidPageState extends State<BidPage> {
  final bidController = TextEditingController();

  Future<void> placeBid() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final bidAmount = int.parse(bidController.text);

    if (bidAmount <= widget.currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid must be higher")),
      );
      return;
    }

    final auctionRef = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId);

    await auctionRef.update({
      'highestBid': bidAmount,
      'highestBidderId': uid,
    });

    await auctionRef.collection('bids').add({
      'bidderId': uid,
      'amount': bidAmount,
      'time': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Place Bid")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Current Highest Bid: ₹${widget.currentBid}"),
            TextField(
              controller: bidController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Your Bid Amount"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: placeBid,
              child: const Text("Submit Bid"),
            ),
          ],
        ),
      ),
    );
  }
}
