import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Puzzle Game',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PuzzleGame()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/one1.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  TextEditingController rowsController = TextEditingController();
  TextEditingController columnsController = TextEditingController();

  int rows = 0;
  int columns = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material widget here
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: rowsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter number of rows'),
            ),
            TextField(
              controller: columnsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter number of columns'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  rows = int.tryParse(rowsController.text) ?? 0;
                  columns = int.tryParse(columnsController.text) ?? 0;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PuzzleTable(rows: rows, columns: columns),
                  ),
                );
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleTable extends StatefulWidget {
  final int rows;
  final int columns;

  PuzzleTable({required this.rows, required this.columns});

  @override
  _PuzzleTableState createState() => _PuzzleTableState();
}

class _PuzzleTableState extends State<PuzzleTable> {
  List<List<String>> grid = [];
  List<List<bool>> highlightedCoordinates = [];

  List<List<bool>> highlightedCells = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    grid = List.generate(
        widget.rows, (row) => List.generate(widget.columns, (col) => ""));
    highlightedCoordinates = List.generate(
        widget.rows, (row) => List.generate(widget.columns, (col) => false));
    highlightedCells = List.generate(
        widget.rows, (row) => List.generate(widget.columns, (col) => false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Puzzle Table'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.columns,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: widget.rows * widget.columns,
              itemBuilder: (context, index) {
                int row = index ~/ widget.columns;
                int col = index % widget.columns;

                String cellValue = grid[row][col];
                bool isHighlighted = highlightedCells[row][col];

                return GestureDetector(
                  onTap: () {
                    _showAlphabetInputDialog(context, row, col);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: isHighlighted ? Colors.yellow : Colors.lightBlue,
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: cellValue,
                          style: TextStyle(
                            fontSize: isHighlighted ? 18.0 : 16.0,
                            fontWeight: isHighlighted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: 'Search Word'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              String searchTerm = searchController.text.toUpperCase();
              print('Search Term: $searchTerm');
              highlightWord(searchTerm);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showAlphabetInputDialog(BuildContext context, int row, int col) async {
    TextEditingController alphabetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Alphabet'),
          content: TextField(
            controller: alphabetController,
            maxLength: 1,
            autofocus: true,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String alphabet = alphabetController.text.toUpperCase();
                setState(() {
                  grid[row][col] = alphabet;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void highlightWord(String word) {
    int wordLength = word.length;

    for (int i = 0; i < widget.rows; i++) {
      for (int j = 0; j < widget.columns; j++) {
        if (j + wordLength <= widget.columns) {
          String horizontalWord = grid[i].skip(j).take(wordLength).join();
          if (horizontalWord == word) {
            print(
                'Found horizontally at: ($i, $j) to ($i, ${j + wordLength - 1})');
            highlightCells(i, j, i, j + wordLength - 1);
            return;
          }
        }

        if (i + wordLength <= widget.rows) {
          String verticalWord =
              List.generate(wordLength, (index) => grid[i + index][j]).join();
          if (verticalWord == word) {
            print(
                'Found vertically at: ($i, $j) to (${i + wordLength - 1}, $j)');
            highlightCells(i, j, i + wordLength - 1, j);
            return;
          }

          if (j + wordLength <= widget.columns) {
            String diagonalWord =
                List.generate(wordLength, (index) => grid[i + index][j + index])
                    .join();
            if (diagonalWord == word) {
              print(
                  'Found diagonally at: ($i, $j) to (${i + wordLength - 1}, ${j + wordLength - 1})');
              highlightCells(i, j, i + wordLength - 1, j + wordLength - 1);
              return;
            }
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Word Not Found'),
          content: Text('The word "$word" is not present in the grid.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void highlightCells(int startRow, int startCol, int endRow, int endCol) {
    for (int i = startRow; i <= endRow; i++) {
      for (int j = startCol; j <= endCol; j++) {
        highlightedCells[i][j] = true;
      }
    }
    setState(() {});
  }
}
