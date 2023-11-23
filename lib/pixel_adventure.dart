import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:platformer/components/level.dart';
import 'package:platformer/components/player.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  late JoystickComponent joystick;
  Player player = Player(character: 'Ninja Frog');
  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    if (Platform.isIOS || Platform.isAndroid) showJoystick = true;
    await images.loadAllImages(); // loads all images from assets into cache

    final world = Level(levelName: 'level-02.tmx', player: player);

    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);
    cam.priority = 0;
    cam.viewfinder.anchor = Anchor.topLeft;

    // adds in multiple things into the FLame World widget
    addAll([cam, world]);

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
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }
}
