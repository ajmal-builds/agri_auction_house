import 'package:flutter/material.dart';

class AuctionCard extends StatelessWidget {
  final String commodity;
  final int price;
  final Widget timer;

  const AuctionCard({
    super.key,
    required this.commodity,
    required this.price,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.agriculture, color: Colors.green),
        title: Text(commodity),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Price: ₹$price"),
            timer,
          ],
        ),
        trailing: const Icon(Icons.gavel),
      ),
    );
  }
}
