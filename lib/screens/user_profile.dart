import 'package:flutter/material.dart';
import 'orders/buyer_order_history.dart';
import 'auction_history.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              "User Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          /// 🛒 MY ORDERS (BUYER)
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("My Orders"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BuyerOrderHistoryPage(),
                  ),
                );
              },
            ),
          ),

          /// 🏆 WON AUCTIONS
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text("Won Auctions"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuctionHistoryPage(),
                  ),
                );
              },
            ),
          ),

          /// 🏪 SOLD AUCTIONS
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: const Text("Sold Auctions"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuctionHistoryPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
