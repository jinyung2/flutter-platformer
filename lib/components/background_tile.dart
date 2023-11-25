import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  final double scrollSpeed = 100;
  BackgroundTile({super.position, this.color = 'Gray'});

  @override
  FutureOr<void> onLoad() async {
    priority = -1;
    parallax = await game.loadParallax(
      [ParallaxImageData("Background/$color.png")],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    return super.onLoad();
  }
}
