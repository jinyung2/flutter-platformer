import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:platformer/levels/level.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  final world = Level();

  @override
  FutureOr<void> onLoad() {
    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);
    cam.viewfinder.anchor = Anchor.topLeft;

    // adds in multiple things into the FLame World widget
    addAll([cam, world]);
    return super.onLoad();
  }
}
