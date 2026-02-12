import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'orders/buyer_order_history.dart';
import 'auction_history.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("User data not found"));
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// 👤 PROFILE IMAGE
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      userData['profileImage'] != null &&
                              userData['profileImage'] != ""
                          ? NetworkImage(userData['profileImage'])
                          : null,
                  child: userData['profileImage'] == null ||
                          userData['profileImage'] == ""
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: 15),

              /// 👤 NAME
              Center(
                child: Text(
                  userData['name'] ?? "User",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  userData['email'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 25),

              /// 🛒 MY ORDERS
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text("My Orders"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BuyerOrderHistoryPage(),
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
                        builder: (_) =>
                            const AuctionHistoryPage(),
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
                        builder: (_) =>
                            const AuctionHistoryPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
