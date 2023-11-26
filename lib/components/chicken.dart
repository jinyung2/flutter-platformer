import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:platformer/components/player.dart';
import 'package:platformer/pixel_adventure.dart';

enum ChickenState { hit, idle, running }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offsetNegative;
  final double offsetPositive;

  Chicken({
    super.size,
    super.position,
    this.offsetNegative = 0,
    this.offsetPositive = 0,
  });

  // this is a reference to our player
  late final Player player;
  double rangeNegative = 0;
  double rangePositive = 0;
  Vector2 velocity = Vector2.zero();
  double moveDirection = 1;
  double targetDirection = -1;
  double moveSpeed = Random().nextInt(50) + 50;

  static const double bounceHeight = 200;

  bool isDead = false;

  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;

  @override
  FutureOr<void> onLoad() {
    player = game.player;

    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 28)));
    _loadAllAnimation();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isDead) {
      _updateState();
      _onMovement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimation() {
    hitAnimation = _loadAnimation(5, 'Hit (32x34).png')..loop = false;
    idleAnimation = _loadAnimation(13, 'Idle (32x34).png');
    runningAnimation = _loadAnimation(14, 'Run (32x34).png');

    animations = {
      ChickenState.hit: hitAnimation,
      ChickenState.idle: idleAnimation,
      ChickenState.running: runningAnimation,
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _loadAnimation(int amount, String filename,
      {stepTime = 0.05}) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chicken/$filename'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2(32, 34)));
  }

  void _calculateRange() {
    const tileSize = 16;
    rangeNegative = position.x - offsetNegative * tileSize;
    rangePositive = position.x + offsetPositive * tileSize;
  }

  void _onMovement(dt) {
    velocity.x = 0;

    double playerOffset = player.scale.x > 0 ? 0 : -player.width;
    double chickenOffset = scale.x > 0 ? 0 : -width;

    if (playerInRange(playerOffset)) {
      targetDirection =
          player.x + playerOffset < position.x + chickenOffset ? -1 : 1;
      velocity.x = targetDirection * moveSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool playerInRange(double playerOffset) {
    return player.x + playerOffset >= rangeNegative &&
        player.x + playerOffset <= rangePositive &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = velocity.x != 0 ? ChickenState.running : ChickenState.idle;
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void hasCollidedWithPlayer() async {
    final bool isPlayerFalling = player.velocity.y > 0;
    final double bottomOfPlayer = player.y + player.height;
    final double topOfChicken = position.y;
    if (isPlayerFalling && bottomOfPlayer > topOfChicken) {
      if (game.playSounds) {
        FlameAudio.play('squeak.mp3', volume: game.soundVolume);
      }
      isDead = true;
      current = ChickenState.hit;
      player.velocity.y = -bounceHeight;

      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}
