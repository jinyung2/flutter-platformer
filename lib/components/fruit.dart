import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:platformer/components/hitbox.dart';
import 'package:platformer/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String name;
  final int amount;
  bool _isCollected = false;
  Fruit(
      {super.position,
      super.size,
      this.name = 'Apple',
      this.amount = 17,
      super.removeOnFinish = true});

  final double stepTime = 0.10;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$name.png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
    return super.onLoad();
  }

  void hasCollidedWithPlayer() {
    if (!_isCollected) {
      if (game.playSounds) {
        FlameAudio.play('fruit.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: stepTime,
            textureSize: Vector2.all(32),
            loop: false,
          ));
      _isCollected = true;
    }
  }
}
