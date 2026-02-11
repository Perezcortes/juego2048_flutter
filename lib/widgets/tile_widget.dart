import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final double size;

  const TileWidget({super.key, required this.value, required this.size});

  Color getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.orange[100]!;
      case 4:
        return Colors.orange[200]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.deepOrange[500]!;
      case 64:
        return Colors.deepOrange[700]!;
      case 128:
        return Colors.yellow[600]!;
      case 256:
        return Colors.yellow[700]!;
      case 512:
        return Colors.yellow[800]!;
      case 1024:
        return Colors.yellow[900]!;
      case 2048:
        return Colors.purpleAccent;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      decoration: BoxDecoration(
        color: value == 0 ? const Color(0xFFCDC1B4) : getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: value == 0
            ? null
            : Text(
                "$value",
                style: TextStyle(
                  fontSize: value > 512 ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: value <= 4 ? const Color(0xFF776E65) : Colors.white,
                ),
              ),
      ),
    );
  }
}
