import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  Future<void> createOrderFromAuction(String auctionId) async {
    final auctionRef = _db.collection('auctions').doc(auctionId);
    final auctionSnap = await auctionRef.get();

    if (!auctionSnap.exists) return;

    final data = auctionSnap.data()!;

    // Only close if auction has bids
    if (data['highestBidderId'] == null) return;

    // 1️⃣ Create order
    await _db.collection('orders').add({
      'auctionId': auctionId,
      'buyerId': data['highestBidderId'],
      'sellerId': data['sellerId'],
      'amount': data['highestBid'],
      'status': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ Close auction
    await auctionRef.update({
      'status': 'ended',
    });
  }
}
