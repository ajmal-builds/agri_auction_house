import 'dart:async';
import 'package:flutter/material.dart';

class AuctionTimer extends StatefulWidget {
  final DateTime endTime;

  const AuctionTimer({
    super.key,
    required this.endTime,
  });

  @override
  State<AuctionTimer> createState() => _AuctionTimerState();
}

class _AuctionTimerState extends State<AuctionTimer> {
  late Timer _timer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final diff = widget.endTime.difference(DateTime.now());

    setState(() {
      remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (remaining == Duration.zero) {
      return const Text(
        "Auction Ended",
        style: TextStyle(color: Colors.red),
      );
    }

    return Text(
      "${remaining.inHours.toString().padLeft(2, '0')}:"
      "${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:"
      "${(remaining.inSeconds % 60).toString().padLeft(2, '0')}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}
