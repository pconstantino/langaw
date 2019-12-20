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
import 'package:langaw/view.dart';
import 'package:langaw/views/home-view.dart';
import 'package:langaw/components/start-button.dart';
import 'package:langaw/views/lost-view.dart';
import 'package:langaw/controllers/spawner.dart';
import 'package:langaw/components/credits-button.dart';
import 'package:langaw/components/help-button.dart';
import 'package:langaw/views/help-view.dart';
import 'package:langaw/views/credits-view.dart';
import 'package:langaw/components/score-display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langaw/components/highscore-display.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:langaw/components/music-button.dart';
import 'package:langaw/components/sound-button.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Random random;
  Backyard background;
  View activeView = View.home;
  HomeView homeView;
  StartButton startButton;
  LostView lostView;
  FlySpawner spawner;
  HelpButton helpButton;
  CreditsButton creditsButton;
  HelpView helpView;
  CreditsView creditsView;
  int score;
  ScoreDisplay scoreDisplay;
  HighscoreDisplay highscoreDisplay;
  AudioPlayer homeBGM;
  AudioPlayer playingBGM;
  MusicButton musicButton;
  SoundButton soundButton;
  final SharedPreferences storage;

  LangawGame(this.storage) {
    initialize();
  }

  @override
  void render(Canvas canvas) {
    //background
    background.render(canvas);

    //highscore
    highscoreDisplay.render(canvas);

    //score
    if (activeView == View.playing) scoreDisplay.render(canvas);

    //Flies
    for (Fly fly in flies) {
      fly.render(canvas);
    }

    musicButton.render(canvas);
    soundButton.render(canvas);

    if (activeView == View.home) {
      homeView.render(canvas);
    }
    if (activeView == View.lost) {
      lostView.render(canvas);
    }
    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
    if (activeView == View.help) {
      helpView.render(canvas);
    }
    if (activeView == View.credits) {
      creditsView.render(canvas);
    }
  }

  @override
  void update(double t) {
    for (Fly fly in flies) {
      fly.update(t);
    }

    flies.removeWhere((Fly fly) => fly.isOffScreen);
    spawner.update(t);

    if (activeView == View.playing) {
      scoreDisplay.update(t);
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;

    //dialog boxes
    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // music button
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // sound button
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }

    // help button
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    //credits button
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    //start button
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    //flies
    if (!isHandled) {
      bool didHitAFly = false;
      for (Fly fly in flies) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          didHitAFly = true;
          isHandled = true;
        }
      }
      if (activeView == View.playing && !didHitAFly) {
        if (soundButton.isEnabled) {
          Flame.audio
              .play('sfx/haha' + (random.nextInt(5) + 1).toString() + '.ogg');
        }
        playHomeBGM();
        activeView = View.lost;
      }
    }
  }

  void initialize() async {
    flies = List<Fly>();
    random = Random();
    resize(await Flame.util.initialDimensions());

    background = Backyard(game: this);
    homeView = HomeView(this);
    startButton = StartButton(this);
    lostView = LostView(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    musicButton = MusicButton(this);
    soundButton = SoundButton(this);
    scoreDisplay = ScoreDisplay(this);
    highscoreDisplay = HighscoreDisplay(this);
    homeBGM = await Flame.audio.loop('bgm/home.mp3', volume: .25);
    homeBGM.pause();
    playingBGM = await Flame.audio.loop('bgm/playing.mp3', volume: .25);
    playingBGM.pause();

    playHomeBGM();
    spawner = FlySpawner(this);
  }

  void spawnFly() {
    double x = random.nextDouble() * (screenSize.width - (tileSize * 1.35));
    double y = (random.nextDouble() * (screenSize.height - (tileSize * 2.85))) +
        (tileSize * 1.5);

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

  void playHomeBGM() {
    playingBGM.pause();
    playingBGM.seek(Duration.zero);
    homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    homeBGM.seek(Duration.zero);
    playingBGM.resume();
  }
}
