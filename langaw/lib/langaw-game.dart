import 'dart:ui';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:langaw/components/backyard.dart';
import 'package:langaw/components/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:langaw/components/house-fly.dart';
import 'package:langaw/components/agile-fly.dart';
import 'package:langaw/components/drooler-fly.dart';
import 'package:langaw/components/hungry-fly.dart';
import 'package:langaw/components/macho-fly.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Random random;
  Backyard background;

  LangawGame() {
    initialize();
  }

  @override
  void render(Canvas canvas) {
    background.render(canvas);

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

    background = Backyard(game: this);

    spawnFly();
  }

  void spawnFly() {
    double x = random.nextDouble() * (screenSize.width - (tileSize * 2.025));
    double y = random.nextDouble() * (screenSize.height - (tileSize * 2.025));

    switch (random.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }
}
