import 'package:langaw/langaw-game.dart';
import 'package:langaw/components/fly.dart';

class FlySpawner {
  final int maxSpawnInterval = 3000;
  final int minSpawnInterval = 250;
  final int intervalChange = 3;
  final int maxFliesOnScreen = 7;
  int currentInterval;
  int nextSpawn;

  final LangawGame game;

  FlySpawner(this.game) {
    start();
    game.spawnFly();
  }

  void start() {
    killAll();
    currentInterval = maxSpawnInterval;
    nextSpawn = DateTime
        .now()
        .millisecondsSinceEpoch + currentInterval;
  }

  void killAll() {
    for (Fly fly in game.flies) {
      fly.isDead = true;
    }
  }

  void update(double t) {
    int nowTimestamp = DateTime
        .now()
        .millisecondsSinceEpoch;

    int livingFlies = 0;
    for (Fly fly in game.flies) {
      if (!fly.isDead) {
        livingFlies += 1;
      }
    }

    if (nowTimestamp >= nextSpawn && livingFlies < maxFliesOnScreen) {
      game.spawnFly();
      if (currentInterval > minSpawnInterval) {
        currentInterval -= intervalChange;
        currentInterval -= (currentInterval * .02).toInt();
      }
      nextSpawn = nowTimestamp + currentInterval;
    }
  }
}
