import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:platformer/components/hitbox.dart';
import 'package:platformer/components/player.dart';
import 'package:platformer/pixel_adventure.dart';

const stepTime = 0.03;

enum FlagState { idle, flagOut, closed }

class Checkpoint extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  bool _isFlagOut = false;
  final hitbox = CustomHitbox(offsetX: 18, offsetY: 16, width: 10, height: 48);

  Checkpoint({super.position, super.size});

  late SpriteAnimation idleAnimation;
  late SpriteAnimation flagOutAnimation;
  late SpriteAnimation closedAnimation;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {}
    super.onCollision(intersectionPoints, other);
  }

  void allFruitsCollected() {
    if (!_isFlagOut) {
      _isFlagOut = true;
      current = FlagState.flagOut;
      final flagOutAnimation = animationTickers![FlagState.flagOut];
      flagOutAnimation!.onComplete = () {
        current = FlagState.idle;
      };
    }
  }

  void _loadAllAnimations() {
    closedAnimation =
        _loadAnimation(1, 'Checkpoint (No Flag).png', loop: false);
    flagOutAnimation =
        _loadAnimation(26, 'Checkpoint (Flag Out) (64x64).png', loop: false);
    idleAnimation = _loadAnimation(10, 'Checkpoint (Flag Idle)(64x64).png');

    animations = {
      FlagState.idle: idleAnimation,
      FlagState.flagOut: flagOutAnimation,
      FlagState.closed: closedAnimation,
    };

    current = FlagState.closed;
  }

  SpriteAnimation _loadAnimation(int amount, String filename,
      {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Checkpoints/Checkpoint/$filename'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(64),
          loop: loop,
        ));
  }
}
