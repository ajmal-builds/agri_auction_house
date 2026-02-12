import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/image_upload_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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
  final minOrderController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  Position? currentPosition;
  bool isLoading = false;

  /// 📍 GET LIVE LOCATION
  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    currentPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() => selectedImages.add(image));
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> urls = [];
    for (final img in selectedImages) {
      final url = await ImageUploadService.uploadImage(img);
      urls.add(url);
    }
    return urls;
  }

  Future<void> createAuction() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload at least one image")),
      );
      return;
    }

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please share your location")),
      );
      return;
    }

    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final auctionRef =
        FirebaseFirestore.instance.collection('auctions').doc();

    final imageUrls = await uploadImages();

    await auctionRef.set({
      'commodityName': commodityController.text.trim(),
      'quantity': quantityController.text.trim(),
      'minOrderQuantity': minOrderController.text.trim(),
      'basePrice': int.parse(basePriceController.text),
      'highestBid': int.parse(basePriceController.text),
      'sellerId': uid,
      'images': imageUrls,
      'location': {
        'lat': currentPosition!.latitude,
        'lng': currentPosition!.longitude,
      },
      'status': 'pending',
      'approved': false,
      'createdAt': FieldValue.serverTimestamp(),
      'endTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Auction sent for admin verification")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Auction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: commodityController,
                decoration: const InputDecoration(labelText: "Commodity Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: minOrderController,
                decoration: const InputDecoration(
                    labelText: "Minimum Order Quantity"),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: basePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Base Price"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 15),

              /// 🖼 IMAGE PREVIEW
              Wrap(
                spacing: 10,
                children: selectedImages.map((img) {
                  return FutureBuilder<Uint8List>(
                    future: img.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Image.memory(
                        snapshot.data!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

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

              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: Text(
                  currentPosition == null
                      ? "Share My Location"
                      : "Location Added ✓",
                ),
                onPressed: getLocation,
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: isLoading ? null : createAuction,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Submit Auction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
