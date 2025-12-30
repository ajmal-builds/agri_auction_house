import 'package:flutter/material.dart';
import '../services/kyc_service.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  String uploadedImageUrl = ""; // later from Firebase Storage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KYC Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: "ID Number (Aadhaar / Govt ID)",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                labelText: "Bank / UPI ID",
              ),
            ),

            const SizedBox(height: 20),

            /// 🔽 PASTE YOUR BUTTON HERE 🔽
            ElevatedButton(
              onPressed: () async {
                await KycService().submitKyc(
                  idNumber: idController.text,
                  address: addressController.text,
                  bankUpi: upiController.text,
                  idProofUrl: uploadedImageUrl,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('KYC Submitted Successfully'),
                  ),
                );
              },
              child: const Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}
