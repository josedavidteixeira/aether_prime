import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

// ------------------- CORES PADRÃO -------------------
const Color buttonTextColor = Color(0xFF222222); // tom escuro padronizado

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}

// ------------------- MENU -------------------
class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🚀 AETHER PRIME 🚀",
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpaceGame()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text("Start",
                    style: TextStyle(fontSize: 18, color: buttonTextColor)),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreditsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text("Créditos",
                    style: TextStyle(fontSize: 18, color: buttonTextColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- CRÉDITOS -------------------
class CreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Créditos"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          "Desenvolvedores:\nJosé David Teixeira da Conceição\nGabriel Gomes Souza",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

// ------------------- JOGO -------------------
class SpaceGame extends StatefulWidget {
  @override
  _SpaceGameState createState() => _SpaceGameState();
}

class _SpaceGameState extends State<SpaceGame> {
  double spaceshipX = 0.5;
  List<Map<String, double>> obstacles = [];
  int score = 0;
  bool isGameOver = false;
  Random random = Random();

  double baseSpeed = 0.01;
  int baseMaxObstacles = 5;
  int maxObstacles = 5;
  int tick = 0;

  // ------------------- GERAR OBSTÁCULO -------------------
  void generateObstacle() {
    double speed = baseSpeed + random.nextDouble() * 0.01;
    double initialSize = 40 + random.nextDouble() * 20; 
    obstacles.add({
      'x': random.nextDouble(),
      'y': 0.0,
      'speed': speed,
      'size': initialSize,
    });
  }

  // ------------------- ATUALIZAÇÃO DO JOGO -------------------
  void updateGame() {
    if (isGameOver) return;

    setState(() {
      tick++;

      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      double spaceshipWidth = 40;
      double spaceshipHeight = 40;
      double spaceshipBottom = 80;

      
      double difficultyFactor = (score / 200).clamp(0, 10); 
      double speedIncrement = difficultyFactor * 0.002;
      if (speedIncrement > 0.03) speedIncrement = 0.03;

      maxObstacles = baseMaxObstacles + (difficultyFactor ~/ 1);
      if (maxObstacles > 20) maxObstacles = 20;

      for (var obstacle in obstacles) {
        obstacle['y'] = obstacle['y']! + obstacle['speed']! + speedIncrement;
        
        obstacle['size'] = obstacle['size']! + 0.01 + difficultyFactor * 0.002;
        if (obstacle['size']! > 80) obstacle['size'] = 80;
      }

      
      obstacles.removeWhere((obstacle) => obstacle['y']! > 1.0);

   
      while (obstacles.length < maxObstacles) {
        generateObstacle();
      }

   
      double spaceshipLeft = spaceshipX * screenWidth;
      double spaceshipRight = spaceshipLeft + spaceshipWidth;
      double spaceshipTop = screenHeight - spaceshipBottom - spaceshipHeight;
      double spaceshipBottomEdge = spaceshipTop + spaceshipHeight;

      for (var obstacle in obstacles) {
        double circleX = obstacle['x']! * screenWidth;
        double circleY = obstacle['y']! * screenHeight + obstacle['size']! / 2;
        double radius = obstacle['size']! / 2;

        double closestX = circleX.clamp(spaceshipLeft, spaceshipRight);
        double closestY = circleY.clamp(spaceshipTop, spaceshipBottomEdge);

        double distanceX = circleX - closestX;
        double distanceY = circleY - closestY;
        double distance = sqrt(distanceX * distanceX + distanceY * distanceY);

        if (distance < radius) {
          isGameOver = true;
          break;
        }
      }

      score++;
    });
  }

  // ------------------- REINICIAR JOGO -------------------
  void resetGame() {
    setState(() {
      spaceshipX = 0.5;
      obstacles = [];
      score = 0;
      tick = 0;
      isGameOver = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.doWhile(() async {
        updateGame();
        await Future.delayed(Duration(milliseconds: 50));
        return !isGameOver;
      });
    });
  }

  // ------------------- CONTROLES -------------------
  void moveLeft() {
    setState(() {
      spaceshipX -= 0.05;
      if (spaceshipX < 0) spaceshipX = 0;
    });
  }

  void moveRight() {
    setState(() {
      spaceshipX += 0.05;
      if (spaceshipX > 1) spaceshipX = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.doWhile(() async {
        updateGame();
        await Future.delayed(Duration(milliseconds: 50));
        return !isGameOver;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ------------------- TÍTULO DO JOGO ALTERADO -------------------
      appBar: AppBar(
        title: Text('AETHER PRIME - Score: $score'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              left: spaceshipX * MediaQuery.of(context).size.width - 20,
              bottom: 80,
              child: CustomPaint(
                painter: SpaceshipPainter(),
                size: Size(40, 40),
              ),
            ),

           
            for (var obstacle in obstacles)
              Positioned(
                left: obstacle['x']! * MediaQuery.of(context).size.width -
                    (obstacle['size']! / 2),
                top: obstacle['y']! * MediaQuery.of(context).size.height,
                child: Container(
                  width: obstacle['size']!,
                  height: obstacle['size']!,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

       
            if (isGameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Game Over!',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Jogar Novamente',
                            style:
                                TextStyle(fontSize: 18, color: buttonTextColor)),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Menu',
                            style:
                                TextStyle(fontSize: 18, color: buttonTextColor)),
                      ),
                    ),
                  ],
                ),
              ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: moveLeft,
                      child: Icon(Icons.arrow_left),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: moveRight,
                      child: Icon(Icons.arrow_right),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- DESENHO DA NAVE -------------------
class SpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}