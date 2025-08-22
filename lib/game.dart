import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

enum MoveDirection { none, left, right }

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

  List<Map<String, double>> bullets = [];
  final double bulletSpeed = 0.03;

  MoveDirection _moveDirection = MoveDirection.none;
  final double spaceshipSpeed = 0.015;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose(); 
    super.dispose();
  }

  void fireBullet() {
    if (isGameOver) return;
    setState(() {
      bullets.add({'x': spaceshipX, 'y': 0.85});
    });
  }

  // ------------------- GERAR OBSTÁCULO -------------------
  void generateObstacle() {
    double speed = baseSpeed + random.nextDouble() * 0.01;
    double initialSize = 40 + random.nextDouble() * 20; // tamanho inicial 40-60
    obstacles.add({
      'x': random.nextDouble(),
      'y': 0.0,
      'speed': speed,
      'size': initialSize,
    });
  }

  // ------------------- ATUALIZAÇÃO DO JOGO -------------------
  void updateGame() {
    if (!mounted) return;
    if (isGameOver) return;

    setState(() {

      if (_moveDirection == MoveDirection.right) {
        spaceshipX += spaceshipSpeed;
      } else if (_moveDirection == MoveDirection.left) {
        spaceshipX -= spaceshipSpeed;
      }

      spaceshipX = spaceshipX.clamp(0.0, 1.0);

      tick++;

      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      double spaceshipWidth = 40;
      double spaceshipHeight = 40;
      double spaceshipBottom = 80;

      // ------------------- DIFICULDADE PROGRESSIVA -------------------
      double difficultyFactor = (score / 200).clamp(0, 10); // de 0 a 10

      // velocidade das bolinhas aumenta suavemente
      double speedIncrement = difficultyFactor * 0.002;
      if (speedIncrement > 0.03) speedIncrement = 0.03;

      // aumenta quantidade máxima de obstáculos progressivamente
      maxObstacles = baseMaxObstacles + (difficultyFactor ~/ 1);
      if (maxObstacles > 20) maxObstacles = 20;

      // ------------------- ATUALIZAÇÃO DOS OBSTÁCULOS -------------------
      for (var obstacle in obstacles) {
        obstacle['y'] = obstacle['y']! + obstacle['speed']! + speedIncrement;
        // crescimento gradual das bolinhas
        obstacle['size'] = obstacle['size']! + 0.01 + difficultyFactor * 0.002;
        if (obstacle['size']! > 80) obstacle['size'] = 80;
      }

      // remove obstáculos que saíram da tela
      obstacles.removeWhere((obstacle) => obstacle['y']! > 1.0);

      // ------------------- SPAWN CONSTANTE -------------------
      // enquanto houver espaço para obstáculos, gera continuamente
      while (obstacles.length < maxObstacles) {
        generateObstacle();
      }

      for (var bullet in bullets) {
        bullet['y'] = bullet['y']! - bulletSpeed; 
      }
      bullets.removeWhere((bullet) => bullet['y']! < 0);

      List<Map<String, double>> bulletsToRemove = [];
      List<Map<String, double>> obstaclesToRemove = [];

      for (var bullet in bullets) {
        for (var obstacle in obstacles) {
          final bulletX = bullet['x']! * screenWidth;
          final bulletY = bullet['y']! * screenHeight;
          final obstacleX = obstacle['x']! * screenWidth;
          final obstacleY = obstacle['y']! * screenHeight;
          final obstacleRadius = obstacle['size']! / 2;

          final distance = sqrt(pow(bulletX - obstacleX, 2) + pow(bulletY - obstacleY, 2));

          if (distance < obstacleRadius) {
            // Se colidiu, marca ambos para remoção
            bulletsToRemove.add(bullet);
            obstaclesToRemove.add(obstacle);
            score += 10; // Adiciona 10 pontos por obstáculo destruído
          }
        }
      }

      // Remove os itens que colidiram
      obstacles.removeWhere((obs) => obstaclesToRemove.contains(obs));
      bullets.removeWhere((bul) => bulletsToRemove.contains(bul));

      // ------------------- DETECÇÃO DE COLISÃO -------------------
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
      _moveDirection = MoveDirection.none;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      Future.doWhile(() async {
        updateGame();
        await Future.delayed(Duration(milliseconds: 50));
        return !isGameOver;
      });
    });
  }

  // ------------------- CONTROLES -------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
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
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          final isLeftPressed = event.logicalKey == LogicalKeyboardKey.arrowLeft;
          final isRightPressed = event.logicalKey == LogicalKeyboardKey.arrowRight;
          final isSpacePressed = event.logicalKey == LogicalKeyboardKey.space;

          if (event is KeyDownEvent) {
            if (isLeftPressed) {
              setState(() => _moveDirection = MoveDirection.left);
            } else if (isRightPressed) {
              setState(() => _moveDirection = MoveDirection.right);
            } else if (isSpacePressed) {
              fireBullet();
            }
          } else if (event is KeyUpEvent) {
            // Para de mover apenas se a tecla solta for a da direção atual
            if ((isLeftPressed && _moveDirection == MoveDirection.left) ||
                (isRightPressed && _moveDirection == MoveDirection.right)) {
              setState(() => _moveDirection = MoveDirection.none);
            }
          }
        },
      child: Container(
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

            // Obstáculos como círculos cinza
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

              for (var bullet in bullets)
              Positioned(
                left: bullet['x']! * MediaQuery.of(context).size.width - 2.5, // Centraliza o tiro
                top: bullet['y']! * MediaQuery.of(context).size.height,
                child: Container(
                  width: 5,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

            // Tela de Game Over
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
                      // Botão Esquerdo
                      GestureDetector(
                        onTapDown: (_) => setState(() => _moveDirection = MoveDirection.left),
                        onTapUp: (_) {
                          if (_moveDirection == MoveDirection.left) {
                            setState(() => _moveDirection = MoveDirection.none);
                          }
                        },
                        onTapCancel: () {
                           if (_moveDirection == MoveDirection.left) {
                            setState(() => _moveDirection = MoveDirection.none);
                          }
                        },
                        child: CircleAvatar(radius: 35, child: Icon(Icons.arrow_left, size: 40)),
                      ),
                    ElevatedButton(
                      onPressed: fireBullet,
                      child: Icon(Icons.gps_fixed, size: 30),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(25),
                      ),
                    ),
                    GestureDetector(
                        onTapDown: (_) => setState(() => _moveDirection = MoveDirection.right),
                        onTapUp: (_) {
                           if (_moveDirection == MoveDirection.right) {
                            setState(() => _moveDirection = MoveDirection.none);
                          }
                        },
                         onTapCancel: () {
                           if (_moveDirection == MoveDirection.right) {
                            setState(() => _moveDirection = MoveDirection.none);
                          }
                        },
                        child: CircleAvatar(radius: 35, child: Icon(Icons.arrow_right, size: 40)),
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