import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final int score;
  final int moves;
  final int maxMoves;
  final int bonusMoves; // Para saber cuánto ganamos este turno
  final VoidCallback onReset;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.moves,
    required this.maxMoves,
    required this.bonusMoves, // Recibimos el bonus
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatBox("SCORE", "$score"),
              const SizedBox(width: 15),
              // Caja de movimientos con animación
              _buildMovesBox(),
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

  Widget _buildMovesBox() {
    // Calculamos movimientos restantes
    int remaining = maxMoves - moves;

    return Column(
      children: [
        const Text(
          "MOVES",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "$moves / $maxMoves",
              style: TextStyle(
                // Si te quedan menos de 10, se pone rojo
                color: remaining < 10 ? Colors.redAccent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // ANIMACIÓN DE BONUS: Si hay bonus, mostramos el +X en verde
            if (bonusMoves > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -10 * value,
                        ), // El texto flota hacia arriba
                        child: Text(
                          "+$bonusMoves",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
