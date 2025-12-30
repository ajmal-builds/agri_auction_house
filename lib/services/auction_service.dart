import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🏆 CLOSE AUCTION & SELECT WINNER
  Future<void> closeAuction(String auctionId) async {
    final auctionRef = _db.collection('auctions').doc(auctionId);
    final auctionSnap = await auctionRef.get();

    if (!auctionSnap.exists) return;

    final data = auctionSnap.data()!;
    final winnerId = data['highestBidderId'];
    final finalPrice = data['highestBid'];

    // ❌ No bids placed
    if (winnerId == null) {
      await auctionRef.update({'status': 'closed'});
      return;
    }

    /// ✅ CREATE ORDER
    await _db.collection('orders').add({
      'auctionId': auctionId,
      'buyerId': winnerId,
      'sellerId': data['sellerId'],
      'amount': finalPrice,
      'paymentStatus': 'pending',
      'deliveryStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    /// ✅ CLOSE AUCTION
    await auctionRef.update({'status': 'closed'});
  }
}
