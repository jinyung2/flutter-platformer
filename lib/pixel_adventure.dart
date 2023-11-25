import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platformer/components/checkpoint.dart';
import 'package:platformer/components/level.dart';
import 'package:platformer/components/player.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  late JoystickComponent joystick;
  Player player = Player(character: 'Ninja Frog');
  Checkpoint checkpoint = Checkpoint();
  bool showJoystick = false;
  bool playSounds = false;
  List<String> levelNames = ['level-02.tmx', 'level-02.tmx'];
  int currentLevelIndex = 0;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) showJoystick = true;
    await images.loadAllImages(); // loads all images from assets into cache

    _loadLevel();

    if (showJoystick) addJoystick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
        priority: 1,
        knob: SpriteComponent(
            sprite: Sprite(
          images.fromCache("HUD/Stick.png"),
        )),
        background: SpriteComponent(
            sprite: Sprite(
          images.fromCache("HUD/Joystick.png"),
        )),
        knobRadius: 24,
        margin: const EdgeInsets.only(left: 64, bottom: 32));

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.downLeft:
      case JoystickDirection.left:
        player.horizontalMovement = -1;
      case JoystickDirection.upLeft:
        player.horizontalMovement = -1;
        player.hasJumped = true;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        player.hasJumped = true;
        break;
      case JoystickDirection.up:
        player.hasJumped = true;
      default:
        if (player.isOnGround) player.horizontalMovement = 0;
        player.hasJumped = false;
    }
  }

  void loadNextLevel() {
    world.removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // loops back to first level
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Level world = Level(
      levelName: levelNames[currentLevelIndex],
      player: player,
      checkpoint: checkpoint,
    );

    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);
    cam.priority = 0;
    cam.viewfinder.anchor = Anchor.topLeft;

    player = Player(character: 'Ninja Frog');

    // adds in multiple things into the FLame World widget
    addAll([cam, world]);
  }
}
