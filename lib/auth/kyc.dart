import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/kyc_service.dart';
import '../services/image_upload_service.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? selectedIdImage;
  bool isSubmitting = false;

  /// 📸 PICK IMAGE
  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => selectedIdImage = image);
    }
  }

  /// 🚀 SUBMIT KYC
  Future<void> submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedIdImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload ID proof image")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final idProofUrl =
        await ImageUploadService.uploadImage(selectedIdImage!);

    await KycService().submitKyc(
      idNumber: idController.text.trim(),
      address: addressController.text.trim(),
      bankUpi: upiController.text.trim(),
      idProofUrl: idProofUrl,
    );

    setState(() => isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("KYC Submitted Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KYC Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// 🆔 ID NUMBER
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "ID Number (Aadhaar / Govt ID)",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "ID number required" : null,
              ),

              const SizedBox(height: 10),

              /// 🏠 ADDRESS
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Address required" : null,
              ),

              const SizedBox(height: 10),

              /// 💳 UPI
              TextFormField(
                controller: upiController,
                decoration: const InputDecoration(
                  labelText: "Bank / UPI ID",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "UPI required" : null,
              ),

              const SizedBox(height: 15),

              /// 🖼️ ID PROOF PREVIEW
              if (selectedIdImage != null)
                Image.network(
                  selectedIdImage!.path,
                  height: 150,
                  fit: BoxFit.cover,
                ),

              const SizedBox(height: 10),

              /// 📸 IMAGE BUTTONS
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    onPressed: () => pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                    onPressed: () => pickImage(ImageSource.gallery),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// ✅ SUBMIT
              ElevatedButton(
                onPressed: isSubmitting ? null : submitKyc,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text("Submit KYC"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
