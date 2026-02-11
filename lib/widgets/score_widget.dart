import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final int score;
  final int moves;
  final int maxMoves;
  final VoidCallback onReset;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.moves,
    required this.maxMoves,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila de Puntaje y Movimientos
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatBox("SCORE", "$score"),
              const SizedBox(width: 15),
              _buildStatBox(
                "MOVES",
                "$moves / $maxMoves",
                isWarning: moves >= maxMoves - 5,
              ), // Alerta visual si quedan pocos
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Reiniciar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool isWarning = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isWarning ? Colors.redAccent : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
