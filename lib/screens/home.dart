import 'package:flutter/material.dart';
import 'create_auction.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agri Auction House')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Create Auction'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateAuctionPage()),
            );
          },
        ),
      ),
    );
  }
}
