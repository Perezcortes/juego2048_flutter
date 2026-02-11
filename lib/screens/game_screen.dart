import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/tile_widget.dart';
import '../widgets/score_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> grid = List.generate(16, (index) => 0);
  int score = 0;

  int moves = 0;
  final int maxMoves = 50;

  bool isGameOver = false;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      grid = List.generate(16, (index) => 0);
      score = 0;
      moves = 0;
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
      grid[randomIndex] = Random().nextInt(10) == 0 ? 4 : 2;
    }
  }

  List<int> mergeRow(List<int> row) {
    List<int> newRow = row.where((e) => e != 0).toList();
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] == newRow[i + 1]) {
        newRow[i] *= 2;
        score += newRow[i];
        if (newRow[i] == 2048) isWon = true;
        newRow.removeAt(i + 1);
      }
    }
    while (newRow.length < 4) {
      newRow.add(0);
    }
    return newRow;
  }

  // 'VoidCallback'
  void move(VoidCallback moveLogic) {
    if (isGameOver || isWon) return;

    // Guardar estado anterior
    List<int> oldGrid = List.from(grid);

    // Ejecutar lógica
    moveLogic();

    // Verificar cambios
    bool hasChanged = false;
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != oldGrid[i]) hasChanged = true;
    }

    if (hasChanged) {
      setState(() {
        moves++;
        addRandomTile();

        if (moves >= maxMoves && !isWon) {
          isGameOver = true;
        } else {
          checkGameOver();
        }
      });
    }
  }

  void checkGameOver() {
    if (!grid.contains(0)) {
      bool canMerge = false;
      for (int i = 0; i < 16; i++) {
        if ((i + 1) % 4 != 0 && grid[i] == grid[i + 1]) canMerge = true;
        if (i < 12 && grid[i] == grid[i + 4]) canMerge = true;
      }
      if (!canMerge) isGameOver = true;
    }
  }

  // --- UI BUILDERS ---

  Widget buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0,
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
            return TileWidget(value: grid[index], size: 60);
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
        // --- CORRECCIÓN DE LLAVES EN LOS IF ---
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            move(() => _moveUpLogic());
          } else if (details.primaryVelocity! > 0) {
            move(() => _moveDownLogic());
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            move(() => _moveLeftLogic());
          } else if (details.primaryVelocity! > 0) {
            move(() => _moveRightLogic());
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
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
                          ScoreWidget(
                            score: score,
                            moves: moves,
                            maxMoves: maxMoves,
                            onReset: startGame,
                          ),
                          const SizedBox(height: 20),
                          buildGrid(),
                        ],
                      );
                    } else {
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
                                ScoreWidget(
                                  score: score,
                                  moves: moves,
                                  maxMoves: maxMoves,
                                  onReset: startGame,
                                ),
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
              if (isGameOver || isWon)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isWon
                              ? "¡Ganaste!"
                              : (moves >= maxMoves
                                    ? "¡Sin movimientos!"
                                    : "Game Over"),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: startGame,
                          child: const Text("Intentar de nuevo"),
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

  // --- LÓGICA PURA DE MATRICES ---
  // --- CORRECCIÓN DE LLAVES EN LOS FOR ---

  void _moveLeftLogic() {
    for (int i = 0; i < 16; i += 4) {
      List<int> row = grid.sublist(i, i + 4);
      List<int> newRow = mergeRow(row);
      for (int j = 0; j < 4; j++) {
        grid[i + j] = newRow[j];
      }
    }
  }

  void _moveRightLogic() {
    for (int i = 0; i < 16; i += 4) {
      List<int> row = grid.sublist(i, i + 4).reversed.toList();
      List<int> newRow = mergeRow(row);
      newRow = newRow.reversed.toList();
      for (int j = 0; j < 4; j++) {
        grid[i + j] = newRow[j];
      }
    }
  }

  void _moveUpLogic() {
    for (int col = 0; col < 4; col++) {
      List<int> column = [
        grid[col],
        grid[col + 4],
        grid[col + 8],
        grid[col + 12],
      ];
      List<int> newCol = mergeRow(column);
      for (int row = 0; row < 4; row++) {
        grid[col + (row * 4)] = newCol[row];
      }
    }
  }

  void _moveDownLogic() {
    for (int col = 0; col < 4; col++) {
      List<int> column = [
        grid[col],
        grid[col + 4],
        grid[col + 8],
        grid[col + 12],
      ].reversed.toList();
      List<int> newCol = mergeRow(column).reversed.toList();
      for (int row = 0; row < 4; row++) {
        grid[col + (row * 4)] = newCol[row];
      }
    }
  }
}
