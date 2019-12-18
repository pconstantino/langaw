import 'dart:ui';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:langaw/components/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/gestures.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Random random;

  LangawGame() {
    initialize();
  }

  @override
  void render(Canvas canvas) {
    Rect backgroundRect =
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint();
    backgroundPaint.color = Color(0xff576574);
    canvas.drawRect(backgroundRect, backgroundPaint);

    //Flies
    for (Fly fly in flies) {
      fly.render(canvas);
    }
  }

  @override
  void update(double t) {
    for (Fly fly in flies) {
      fly.update(t);
    }

    flies.removeWhere((Fly fly) => fly.isOffScreen);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    for (Fly fly in flies) {
      if (fly.flyRect.contains(d.globalPosition)) {
        fly.onTapDown();
      }
    }
  }

  void initialize() async {
    flies = List<Fly>();
    random = Random();
    resize(await Flame.util.initialDimensions());

    spawnFly();
  }

  void spawnFly() {
    double x = random.nextDouble() * (screenSize.width - tileSize);
    double y = random.nextDouble() * (screenSize.height - tileSize);
    flies.add(Fly(game: this, x: x, y: y));
  }
}
