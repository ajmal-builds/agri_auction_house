import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();

  final commodityController = TextEditingController();
  final quantityController = TextEditingController();
  final basePriceController = TextEditingController();

  bool isLoading = false;

  Future<void> createAuction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('auctions').add({
      'commodityName': commodityController.text.trim(),
      'quantity': quantityController.text.trim(),
      'basePrice': int.parse(basePriceController.text),
      'currentBid': int.parse(basePriceController.text),
      'sellerId': uid,
      'status': 'pending', // admin can make it live
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auction Created Successfully')),
    );

    Navigator.pop(context); // go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Auction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: commodityController,
                decoration: const InputDecoration(
                  labelText: "Commodity Name (Cardamom / Pepper)",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Enter commodity name" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity (eg: 50 Kg)",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Enter quantity" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: basePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Base Price (₹)",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Enter base price" : null,
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: isLoading ? null : createAuction,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Create Auction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
