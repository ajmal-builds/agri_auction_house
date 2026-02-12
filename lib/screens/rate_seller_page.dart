import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RateSellerPage extends StatefulWidget {
  final String sellerId;

  const RateSellerPage({super.key, required this.sellerId});

  @override
  State<RateSellerPage> createState() => _RateSellerPageState();
}

class _RateSellerPageState extends State<RateSellerPage> {

  int rating = 5;

  Future<void> submitRating() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.sellerId)
        .collection('ratings')
        .add({
      'rating': rating,
      'time': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Seller")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            value: rating.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: rating.toString(),
            onChanged: (value) {
              setState(() {
                rating = value.toInt();
              });
            },
          ),
          ElevatedButton(
            onPressed: submitRating,
            child: const Text("Submit Rating"),
          )
        ],
      ),
    );
  }
}
