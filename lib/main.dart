import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Puzzle',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Matriz de 4x4 aplanada en una lista de 16 elementos para facilitar el GridView
  List<int> grid = List.generate(16, (index) => 0);
  int score = 0;
  bool isGameOver = false;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  // --- LÓGICA DEL JUEGO ---

  void startGame() {
    setState(() {
      grid = List.generate(16, (index) => 0);
      score = 0;
      isGameOver = false;
      isWon = false;
      addRandomTile();
      addRandomTile();
    });
  }

  void addRandomTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == 0) emptyIndices.add(i);
    }

    if (emptyIndices.isNotEmpty) {
      int randomIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      // 90% probabilidad de un 2, 10% de un 4
      grid[randomIndex] = Random().nextInt(10) == 0 ? 4 : 2;
    }
  }

  // Esta función maneja la fusión de una fila hacia la izquierda
  // Ejemplo: [2, 2, 0, 4] -> [4, 4, 0, 0]
  List<int> mergeRow(List<int> row) {
    // 1. Quitar los ceros: [2, 2, 4]
    List<int> newRow = row.where((e) => e != 0).toList();

    // 2. Fusionar iguales
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] == newRow[i + 1]) {
        newRow[i] *= 2;
        score += newRow[i];
        if (newRow[i] == 2048) isWon = true;
        newRow.removeAt(i + 1);
      }
    }

    // 3. Rellenar con ceros hasta tener 4 elementos
    while (newRow.length < 4) {
      newRow.add(0);
    }
    return newRow;
  }

  void moveLeft() {
    bool hasChanged = false;
    for (int i = 0; i < 16; i += 4) {
      List<int> row = grid.sublist(i, i + 4);
      List<int> newRow = mergeRow(row);
      for (int j = 0; j < 4; j++) {
        if (grid[i + j] != newRow[j]) hasChanged = true;
        grid[i + j] = newRow[j];
      }
    }
    if (hasChanged) {
      addRandomTile();
      checkGameOver();
    }
  }

  void moveRight() {
    // Truco: Invertir fila -> Mover Izquierda -> Invertir fila
    bool hasChanged = false;
    for (int i = 0; i < 16; i += 4) {
      List<int> row = grid.sublist(i, i + 4).reversed.toList();
      List<int> newRow = mergeRow(row);
      newRow = newRow.reversed.toList(); // Volver a invertir
      for (int j = 0; j < 4; j++) {
        if (grid[i + j] != newRow[j]) hasChanged = true;
        grid[i + j] = newRow[j];
      }
    }
    if (hasChanged) {
      addRandomTile();
      checkGameOver();
    }
  }

  void moveUp() {
    // Algoritmo: Transponer matriz (filas x columnas) -> Mover Izquierda -> Transponer de vuelta
    bool hasChanged = false;
    for (int col = 0; col < 4; col++) {
      List<int> column = [
        grid[col],
        grid[col + 4],
        grid[col + 8],
        grid[col + 12],
      ];
      List<int> newCol = mergeRow(column);
      for (int row = 0; row < 4; row++) {
        if (grid[col + (row * 4)] != newCol[row]) hasChanged = true;
        grid[col + (row * 4)] = newCol[row];
      }
    }
    if (hasChanged) {
      addRandomTile();
      checkGameOver();
    }
  }

  void moveDown() {
    bool hasChanged = false;
    for (int col = 0; col < 4; col++) {
      List<int> column = [
        grid[col],
        grid[col + 4],
        grid[col + 8],
        grid[col + 12],
      ].reversed.toList();
      List<int> newCol = mergeRow(column).reversed.toList();
      for (int row = 0; row < 4; row++) {
        if (grid[col + (row * 4)] != newCol[row]) hasChanged = true;
        grid[col + (row * 4)] = newCol[row];
      }
    }
    if (hasChanged) {
      addRandomTile();
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (!grid.contains(0)) {
      // Si está lleno, verificar si se puede fusionar algo
      bool canMerge = false;
      // Verificar horizontal y vertical
      for (int i = 0; i < 16; i++) {
        // Derecha
        if ((i + 1) % 4 != 0 && grid[i] == grid[i + 1]) canMerge = true;
        // Abajo
        if (i < 12 && grid[i] == grid[i + 4]) canMerge = true;
      }
      if (!canMerge) isGameOver = true;
    }
  }

  // --- COLORES SEGÚN EL NÚMERO ---
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

  // --- UI WIDGETS ---

  Widget buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "SCORE",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$score",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: startGame,
            icon: const Icon(Icons.refresh),
            label: const Text("Reiniciar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0, // Cuadrado perfecto
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFBBADA0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            int value = grid[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              decoration: BoxDecoration(
                color: value == 0
                    ? const Color(0xFFCDC1B4)
                    : getTileColor(value),
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
                          color: value <= 4
                              ? const Color(0xFF776E65)
                              : Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: GestureDetector(
        // Detectar gestos (Swipe)
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            setState(() => moveUp());
          } else if (details.primaryVelocity! > 0) {
            setState(() => moveDown());
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            setState(() => moveLeft());
          } else if (details.primaryVelocity! > 0) {
            setState(() => moveRight());
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              // --- RESPONSIVIDAD: OrientationBuilder ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
                      // Diseño Vertical
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "2048",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF776E65),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [buildScoreBoard()],
                          ),
                          const SizedBox(height: 20),
                          buildGrid(),
                        ],
                      );
                    } else {
                      // Diseño Horizontal (Landscape)
                      return Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "2048",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF776E65),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildScoreBoard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: Center(child: buildGrid())),
                        ],
                      );
                    }
                  },
                ),
              ),
              // Overlay de Game Over o Victoria
              if (isGameOver || isWon)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isWon ? "¡Ganaste!" : "Game Over",
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: startGame,
                          child: const Text("Jugar de nuevo"),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
