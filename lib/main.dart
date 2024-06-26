import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(HashTableApp());
}

class HashTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HashTable',
      theme: ThemeData(scaffoldBackgroundColor: Color.fromARGB(31, 31, 31, 1)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _deviceWidth;
  final int tableSize = 10;
  final List<List<String>> table = List.generate(10, (_) => []);
  final TextEditingController inputController = TextEditingController();
  String statusMessage = 'Status: Ready';
  bool isAnimating = false;
  String? animatingKey;
  int animatingIndex = 0;
  int animatingChainPosition = 0;
  double currentX = 0.0, currentY = 0.0;
  double targetX = 0.0, targetY = 0.0;
  Timer? animationTimer;
  int animationStep = 0;
  static const int animationSteps = 20;
  static const int animationDelay = 20;
  bool movingToIndex = true;

  int hashFunction(String key) {
    int hashValue = 0;
    for (int i = 0; i < key.length; i++) {
      hashValue = (hashValue + key.codeUnitAt(i)) * 31;
    }
    return (hashValue % tableSize).abs();
  }

  void startAnimation(String key, int index) {
    setState(() {
      animatingKey = key;
      animatingIndex = index;
      animatingChainPosition = table[index].length;
      animationStep = 0;
      currentX = 10.0;
      currentY = -20.0;
      targetX = 10.0 + (120.0);
      targetY = index * (20.0 + 10.0) + 10.0;
      movingToIndex = true;
    });

    if (animationTimer != null && animationTimer!.isActive) {
      animationTimer!.cancel();
    }

    animationTimer =
        Timer.periodic(Duration(milliseconds: animationDelay), (timer) {
      setState(() {
        if (animationStep < animationSteps) {
          currentX +=
              (targetX - currentX) / (animationSteps - animationStep + 1);
          currentY +=
              (targetY - currentY) / (animationSteps - animationStep + 1);
        } else {
          if (movingToIndex) {
            movingToIndex = false;
            animationStep = 0;
            targetX = 10.0 + (120.0) * (animatingChainPosition + 1);
          } else {
            currentX +=
                (targetX - currentX) / (animationSteps - animationStep + 1);
            if (animationStep >= animationSteps) {
              timer.cancel();
              table[animatingIndex].add(animatingKey!);
              animatingKey = null;
              isAnimating = false;
              statusMessage = 'Added successfully: $key';
            }
          }
        }
        animationStep++;
      });
    });
  }

  void add(String key) {
    if (isAnimating) return;
    int index = hashFunction(key);
    if (!table[index].contains(key)) {
      isAnimating = true;
      startAnimation(key, index);
    } else {
      setState(() {
        statusMessage = 'Key already exists: $key';
      });
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Result"),
          content: Text("Added successfully ${key}"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void remove(String key) {
    int index = hashFunction(key);
    if (table[index].remove(key)) {
      setState(() {
        statusMessage = 'Removed successfully: $key';
      });
    } else {
      setState(() {
        statusMessage = 'Key not found: $key';
      });
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Result"),
          content: Text("Removed successfully ${key}"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int getHashTableSize() {
    int size = 0;
    for (var list in table) {
      size += list.length;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Size Result"),
          content: Text(size.toString()),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return size;
  }

  bool contains(String key) {
    int index = hashFunction(key);
    bool found = table[index].contains(key);
    setState(() {
      statusMessage = found ? "$key'found" : "$key not found";
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contains Result"),
          content: Text(statusMessage),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return found;
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('#HashTable'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width:
                    _deviceWidth, // Set an appropriate width to enable scrolling
                child: CustomPaint(
                  painter: TablePainter(
                    table: table,
                    animatingKey: animatingKey,
                    currentX: currentX,
                    currentY: currentY,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(statusMessage),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                icon: Icon(Icons.play_arrow_sharp, color: Colors.redAccent),
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                labelText: 'Enter  Name',
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  String key = inputController.text.trim();
                  if (key.isNotEmpty) {
                    add(key);
                    inputController.clear();
                  }
                },
                child: SizedBox(
                  width: _deviceWidth,
                  child: Text(
                    'Add',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: "Arial"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  String key = inputController.text.trim();
                  if (key.isNotEmpty) {
                    remove(key);
                    inputController.clear();
                  }
                },
                child: SizedBox(
                  width: _deviceWidth,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: "Arial"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  String key = inputController.text.trim();
                  if (key.isNotEmpty) {
                    contains(key);
                    inputController.clear();
                  }
                },
                child: SizedBox(
                  width: _deviceWidth,
                  child: Text(
                    'contains',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: "Arial"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.yellow.shade600, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  int size = getHashTableSize();
                  setState(() {
                    statusMessage = 'Current size: $size';
                  });
                },
                child: SizedBox(
                  width: _deviceWidth,
                  child: Text(
                    'size',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: "Arial"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TablePainter extends CustomPainter {
  final List<List<String>> table;
  final String? animatingKey;
  final double? currentX, currentY;

  TablePainter(
      {required this.table, this.animatingKey, this.currentX, this.currentY});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const double width = 130.0; // Ajuster la largeur des cellules
    const double height = 30.0; // Ajuster la hauteur des cellules
    const double padding = 5.0;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center, // Centrer le texte horizontalement
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < table.length; i++) {
      double x = padding;
      double y = i * (height + padding) + padding;

      // Dessiner la cellule d'index
      textPainter.text = TextSpan(
        text: '[$i]',
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x + padding, y + (height - textPainter.height) / 2));

      // Dessiner le rectangle de la cellule d'index
      canvas.drawRect(
        Rect.fromLTWH(x, y, width, height),
        paint,
      );

      for (int j = 0; j < table[i].length; j++) {
        double previousX = x;
        x += width + padding;
        canvas.drawRect(
          Rect.fromLTWH(x, y, width, height),
          paint,
        );
        // Dessiner la cellule de valeur
        textPainter.text = TextSpan(
          text: table[i][j],
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(x + padding + (width - textPainter.width) / 2,
                y + (height - textPainter.height) / 2));

        // Dessiner la ligne horizontale
        canvas.drawLine(
          Offset(previousX + width, y + height / 2),
          Offset(x, y + height / 2),
          paint,
        );
      }

      // Dessiner le symbole de fin-de-liste si la liste n'est pas vide
      if (table[i].isNotEmpty) {
        double previousX = x;
        x += width + padding;
        canvas.drawLine(
          Offset(previousX + width, y + height / 2),
          Offset(x, y + height / 2),
          paint,
        );

        // Dessiner la ligne verticale
        canvas.drawLine(
          Offset(x, y + padding),
          Offset(x, y + height - padding),
          paint,
        );

        // Dessiner les tirets horizontaux qui ne traversent pas la ligne verticale
        canvas.drawLine(
          Offset(x, y + padding),
          Offset(x + 4, y + padding),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 4),
          Offset(x + 4, y + 4),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 8),
          Offset(x + 4, y + 8),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 12),
          Offset(x + 4, y + 12),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 16),
          Offset(x + 4, y + 16),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 20),
          Offset(x + 4, y + 20),
          paint,
        );
      }

      // Dessiner l'élément en cours d'animation si nécessaire
      if (animatingKey != null && i == table.length - 1) {
        paint.color = Colors.lightBlue.shade700;
        canvas.drawRect(
          Rect.fromLTWH(currentX!, currentY!, width, height),
          paint,
        );

        textPainter.text = TextSpan(
          text: animatingKey!,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(currentX! + padding,
                currentY! + (height - textPainter.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
