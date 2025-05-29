import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/game_settings.dart';
import 'game/ball.dart';
import 'game/bucket.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameEngine(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();

    // The home page to start the game
    if (!engine.hasStarted) {
      final btnStyle = ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      );
      return Scaffold(
        backgroundColor: Colors.lightBlue.shade100,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Catch The Ball 🏀',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

              // The start buttom
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: engine.start,
                style: btnStyle,
                child: const Text('START', style: TextStyle(fontSize: 20)),
              ),

              // The setting buttom
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showSettings(context, engine),
                style: btnStyle,
                child: const Text('SETTINGS', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      );
    }

    // Here is the screen when the game ends
    if (engine.isGameOver || engine.isWin) {
      final title = engine.isWin ? 'You Win!' : 'Game Over';
      final btnStyle = ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      );
      return Scaffold(
        backgroundColor: Colors.lightBlue.shade100,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              Text('Score: ${engine.score}', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: engine.start,
                style: btnStyle,
                child: const Text('RESTART', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showSettings(context, engine),
                style: btnStyle,
                child: const Text('SETTINGS', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      );
    }


    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).padding.bottom;

    final bucketW    = Bucket.width;
    final bucketH    = Bucket.height;
    final bucketLeft = engine.bucketX * screenW - bucketW / 2;
    final bucketTop  = screenH - bottom - bucketH;
    final bucketRect = Rect.fromLTWH(bucketLeft, bucketTop, bucketW, bucketH);

    final toCatch = <int>[];
    bool missed   = false;

    final children = <Widget>[
      Positioned(
        top: 0, left: 0, right: 0,
        child: Container(
          color: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.sports_basketball, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Score: ${engine.score}', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 16),
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('Level: ${engine.level}', style: const TextStyle(fontSize: 18)),
              ]),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettings(context, engine),
              ),
            ],
          ),
        ),
      ),
    ];

    for (int i = 0; i < engine.balls.length; i++) {
      final b  = engine.balls[i];
      final bs = Ball.size;
      final bx = b.x * screenW - bs / 2;
      final by = b.y * screenH - bs / 2;
      final ballRect = Rect.fromLTWH(bx, by, bs, bs);

      if (by > screenH) {
        missed = true;
        break;
      }
      if (ballRect.overlaps(bucketRect)) {
        toCatch.add(i);
        continue;
      }
      children.add(Positioned(
        left: bx, top: by,
        child: Image.asset(Ball.assetPath, width: bs, height: bs, fit: BoxFit.contain),
      ));
    }

    children.add(Bucket(x: engine.bucketX).build(context));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (missed) {
        engine.missBall();
      } else {
        for (var idx in toCatch.reversed) {
          engine.catchBall(idx);
        }
      }
    });

    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        final box = context.findRenderObject() as RenderBox;
        final x = box.globalToLocal(d.globalPosition).dx / box.size.width;
        engine.moveBucket(x);
      },
      child: Scaffold(
        backgroundColor: Colors.lightBlue.shade100,
        body: SafeArea(child: Stack(children: children)),
      ),
    );
  }

  // settings
  void _showSettings(BuildContext ctx, GameEngine engine) {
    engine.pause();
    final scoreCtl = TextEditingController(text: engine.winScore.toString());
    final speedCtl = TextEditingController(text: engine.speedFactor.toString());

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: scoreCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Winning Score'),
            ),
            TextField(
              controller: speedCtl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Falling Speed (0.3~3)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final ws = int.tryParse(scoreCtl.text) ?? engine.winScore;
              final sf = double.tryParse(speedCtl.text) ?? engine.speedFactor;
              if (sf <= 0.3 || sf >= 3) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Speed Factor must be >0.3 and <3')),
                );
                return;
              }
              engine.winScore    = ws;
              engine.speedFactor = sf;
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      engine.resume();
    });
  }
}
