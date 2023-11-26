import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:platformer/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  static const stepTime = 0.03;
  static const tileSize = 16;
  final moveSpeed = Random().nextInt(100) + 50;
  double moveDirection = 1;
  double rangeNegative = 0;
  double rangePositive = 0;

  final bool isVertical;
  final double offsetNegative;
  final double offsetPositive;

  Saw({
    super.position,
    super.size,
    this.isVertical = false,
    this.offsetNegative = 0,
    this.offsetPositive = 0,
  });

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    if (isVertical) {
      rangeNegative = position.y - offsetNegative * tileSize;
      rangePositive = position.y + offsetPositive * tileSize;
    } else {
      rangeNegative = position.x - offsetNegative * tileSize;
      rangePositive = position.x + offsetPositive * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Saw/On (38x38).png'),
        SpriteAnimationData.sequenced(
            amount: 8, stepTime: stepTime, textureSize: Vector2.all(38)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  _moveVertically(dt) {
    if (position.y >= rangePositive) moveDirection = -1;
    if (position.y < rangeNegative) moveDirection = 1;
    position.y += moveDirection * moveSpeed * dt;
  }

  _moveHorizontally(dt) {
    if (position.x >= rangePositive) moveDirection = -1;
    if (position.x < rangeNegative) moveDirection = 1;
    position.x += moveDirection * moveSpeed * dt;
  }
}
