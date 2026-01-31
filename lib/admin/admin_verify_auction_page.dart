import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVerifyAuctionPage extends StatefulWidget {
  final String auctionId;
  final Map<String, dynamic> auctionData;

  const AdminVerifyAuctionPage({
    super.key,
    required this.auctionId,
    required this.auctionData,
  });

  @override
  State<AdminVerifyAuctionPage> createState() =>
      _AdminVerifyAuctionPageState();
}

class _AdminVerifyAuctionPageState
    extends State<AdminVerifyAuctionPage> {
  final TextEditingController rejectReasonController =
      TextEditingController();

  Future<void> approveAuction() async {
    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId)
        .update({
      'status': 'live',
      'approved': true,
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': widget.auctionData['sellerId'],
      'title': 'Auction Approved',
      'message':
          'Your auction for ${widget.auctionData['commodityName']} is now live.',
      'type': 'auction',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> rejectAuction() async {
    final reason = rejectReasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter rejection reason")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId)
        .update({
      'status': 'rejected',
      'approved': false,
      'rejectionReason': reason,
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': widget.auctionData['sellerId'],
      'title': 'Auction Rejected',
      'message': reason,
      'type': 'auction',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.auctionData;
final List images = (data['images'] ?? []) as List;


    return Scaffold(
      appBar: AppBar(title: const Text("Verify Auction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Commodity", data['commodityName']),
            _info("Quantity", data['quantity']),
            _info("Base Price", "₹${data['basePrice']}"),
const SizedBox(height: 20),
const Text(
  "Product Images",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

const SizedBox(height: 10),
SizedBox(
  height: 120,
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: images.map<Widget>((url) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Image.network(
          url,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image),
        ),
      );
    }).toList(),
  ),
),


            const SizedBox(height: 20),

            TextField(
              controller: rejectReasonController,
              decoration: const InputDecoration(
                labelText: "Rejection Reason (if rejecting)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: approveAuction,
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: rejectAuction,
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "$title: $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
