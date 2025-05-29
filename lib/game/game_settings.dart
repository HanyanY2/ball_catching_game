import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'ball.dart';

class GameEngine extends ChangeNotifier {
  bool hasStarted = false;
  bool isPaused   = false;
  // this flag for pause game when settings opened

  final Random _rand = Random();
  final List<Ball> balls = [];

  int winScore = 35;
  double speedFactor = 1.0;
  // winning score and ball speed

  double bucketX = 0.5;
  int score     = 0;
  int level     = 1;
  bool isGameOver = false;
  bool isWin      = false;

  Timer? _spawnTimer;
  Timer? _updateTimer;

  Duration get spawnInterval =>
      Duration(milliseconds: max(300, 1000 - (level - 1) * 100));
  double get fallSpeed => 0.005 * speedFactor * (1 + 0.5 * (level - 1));
  // the falling speed will increase and the spawn time will reduce
  // when the game level up

  void start() {
    hasStarted  = true;
    isPaused    = false;
    balls.clear();
    bucketX     = 0.5;
    score       = 0;
    level       = 1;
    isGameOver  = false;
    isWin       = false;
    notifyListeners();

    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(spawnInterval, (_) {
      if (!isGameOver && !isWin && !isPaused) {
        balls.add(Ball(x: _rand.nextDouble(), y: 0));
        notifyListeners();
      }
    });

    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!isGameOver && !isWin && !isPaused) {
        for (var b in balls) {
          b.y += fallSpeed;
        }
        notifyListeners();
      }
    });
  }

  // pause game
  void pause() {
    isPaused = true;
    notifyListeners();
  }

 // end pause
  void resume() {
    isPaused = false;
    notifyListeners();
  }

  // winning game flag check
  void _checkWin() {
    if (score >= winScore) {
      winGame();
    }
  }

  void winGame() {
    isWin = true;
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    notifyListeners();
  }

  void catchBall(int index) {
    balls.removeAt(index);
    score++;
    if (score % 5 == 0) {
      // level up every 5 balls were caught
      level++;
      _spawnTimer?.cancel();
      _spawnTimer = Timer.periodic(spawnInterval, (_) {
        if (!isGameOver && !isWin && !isPaused) {
          balls.add(Ball(x: _rand.nextDouble(), y: 0));
          notifyListeners();
        }
      });
    }
    notifyListeners();
    _checkWin();
  }

  // you will game over when you miss a ball
  void missBall() {
    isGameOver = true;
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    notifyListeners();
  }

  void moveBucket(double newX) {
    bucketX = newX.clamp(0.0, 1.0);
    notifyListeners();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }
}
