import 'package:flutter/material.dart';

class PreviewTrack extends StatelessWidget {
  const PreviewTrack({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFEE9AE5), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 28),
      ),
    );
  }
}
