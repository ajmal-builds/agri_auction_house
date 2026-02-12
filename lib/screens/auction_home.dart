import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'create_auction.dart';
import 'bid_page.dart';
import 'auction_history.dart';
import 'user_profile.dart';
import '../widgets/auction_timer.dart';
import 'user_notifications.dart';
import 'map_view_page.dart';
import 'full_screen_image.dart';

class AuctionHomePage extends StatefulWidget {
  const AuctionHomePage({super.key});

  @override
  State<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends State<AuctionHomePage> {
  String searchQuery = "";

  Future<void> autoCompleteAuction(
    String auctionId,
    Map<String, dynamic> data,
) async {

  if (data['status'] == 'completed') return;

  final endTime = (data['endTime'] as Timestamp?)?.toDate();
  if (endTime == null) return;

  if (DateTime.now().isAfter(endTime)) {

    final winner = data['highestBidderId'];

    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(auctionId)
        .update({'status': 'completed'});

    if (winner != null) {
      await FirebaseFirestore.instance.collection('orders').add({
        'auctionId': auctionId,
        'sellerId': data['sellerId'],
        'buyerId': winner,
        'amount': data['highestBid'],
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Auction House'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UserNotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData =
            snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return const Center(child: Text("User data not found"));
            }

            if (userData['kycStatus'] != 'approved') {
              return const Center(
                child: Text("KYC Pending Approval"),
              );
            }

            return Column(
              children: [

                /// 🔍 SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search spice, quantity or price...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

                /// 📦 AUCTION LIST
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('auctions')
                        .where('status', isEqualTo: 'live')
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final auctions = snapshot.data!.docs.where((doc) {
                        final data =
                        doc.data() as Map<String, dynamic>;

                        final name =
                        (data['commodityName'] ?? "")
                            .toString()
                            .toLowerCase();

                        return name.contains(searchQuery);
                      }).toList();

                      if (auctions.isEmpty) {
                        return const Center(
                            child: Text("No live auctions"));
                      }

                      return ListView.builder(
                        itemCount: auctions.length,
                        itemBuilder: (context, index) {

                          final doc = auctions[index];
                          final auction =
                          doc.data() as Map<String, dynamic>;

                          autoCompleteAuction(doc.id, auction);

                          final images =
                              auction['images'] as List<dynamic>? ?? [];

                          final location = auction['location'];

                          final endRaw = auction['endTime'];
                          DateTime? endTime;
                          if (endRaw is Timestamp) {
                            endTime = endRaw.toDate();
                          }

                          double progress = 0;
                          if (endTime != null) {
                            final total = 86400;
                            final remaining =
                                endTime.difference(DateTime.now()).inSeconds;
                            progress = remaining > 0
                                ? remaining / total
                                : 0;
                          }

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(auction['sellerId'])
                                .get(),
                            builder: (context, sellerSnap) {

                              final sellerName =
                                  sellerSnap.data?.get('name') ??
                                      "Seller";

                              return Container(
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF66BB6A)
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        /// 🔥 IMAGE CAROUSEL
                                        if (images.isNotEmpty)
                                          CarouselSlider(
                                            options:
                                            CarouselOptions(
                                              height: 180,
                                              autoPlay: true,
                                            ),
                                            items: images.map<Widget>((img) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          FullScreenImagePage(
                                                            imageUrl: img,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                  child: Image.network(
                                                    img,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                        const SizedBox(height: 10),

                                        Text(
                                          auction['commodityName'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),

                                        Text(
                                          "Seller: $sellerName",
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          "Min Order: ${auction['minOrderQuantity'] ?? '-'}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),

                                        Text(
                                          "Current Bid: ₹${auction['highestBid']}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),

                                        const SizedBox(height: 8),

                                        if (endTime != null)
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              LinearProgressIndicator(
                                                value: progress,
                                                backgroundColor:
                                                Colors.white24,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(height: 4),
                                              AuctionTimer(
                                                  endTime: endTime),
                                            ],
                                          ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [

                                            Expanded(
                                              child: ElevatedButton(
                                                child: const Text("Place Bid"),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          BidPage(
                                                            auctionId: doc.id,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            if (location != null)
                                              IconButton(
                                                icon:
                                                const Icon(Icons.map,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          MapViewPage(
                                                            lat: location['lat'],
                                                            lng: location['lng'],
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Sell Commodity'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateAuctionPage()),
          );
        },
      ),
    );
  }
}
