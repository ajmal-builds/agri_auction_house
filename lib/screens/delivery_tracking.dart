import 'package:flutter/material.dart';

class DeliveryTrackingPage extends StatelessWidget {
  final String status;
  final String location;

  const DeliveryTrackingPage({
    super.key,
    required this.status,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Tracking")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📦 Delivery Status",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),

            Text("Current Status: $status",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Text("📍 Current Location:",
                style: Theme.of(context).textTheme.titleMedium),
            Text(location),

            const SizedBox(height: 30),

            LinearProgressIndicator(
              value: status == "pending"
                  ? 0.3
                  : status == "shipped"
                      ? 0.6
                      : 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
