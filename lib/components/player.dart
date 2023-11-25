import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:platformer/components/checkpoint.dart';
import 'package:platformer/components/collision_block.dart';
import 'package:platformer/components/fruit.dart';
import 'package:platformer/components/hitbox.dart';
import 'package:platformer/components/saw.dart';
import 'package:platformer/pixel_adventure.dart';
import 'package:platformer/utils/collisions.dart';

enum PlayerState {
  idle,
  running,
  doubleJump,
  jump,
  wallJump,
  fall,
  hit,
  spawning,
  disappearing,
}

const playerStateToImg = {
  PlayerState.idle: 'Idle (32x32).png',
  PlayerState.running: 'Run (32x32).png',
  PlayerState.doubleJump: 'Double Jump (32x32).png',
  PlayerState.jump: 'Jump (32x32).png',
  PlayerState.wallJump: 'Wall Jump (32x32).png',
  PlayerState.fall: 'Fall (32x32).png',
  PlayerState.hit: 'Hit (32x32).png',
  PlayerState.spawning: 'Appearing (96x96).png',
  PlayerState.disappearing: 'Disappearing (96x96).png',
};
const playerStateToImgCount = {
  PlayerState.idle: 11,
  PlayerState.running: 12,
  PlayerState.doubleJump: 6,
  PlayerState.jump: 1,
  PlayerState.wallJump: 5,
  PlayerState.fall: 1,
  PlayerState.hit: 7,
  PlayerState.spawning: 7,
  PlayerState.disappearing: 7,
};

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  final double stepTime = 0.05;
  late String character;
  Player({
    super.position,
    this.character = 'Ninja Frog',
  });

  // animations
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation wallJumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation spawningAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 980;
  final double _jumpForce = 310;
  final double _terminalVelocity = 500;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool _hasReachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  int fruitCount = 0;

  @override
  FutureOr<void> onLoad() {
    _onLoadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !_hasReachedCheckpoint) {
      _updatePlayerMovement(dt);
      _updatePlayerState();
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_hasReachedCheckpoint) {
      if (other is Fruit) {
        if (game.playSounds) {
          FlameAudio.play('fruit.wav', volume: game.soundVolume);
        }
        other.hasCollidedWithPlayer();
      } else if (other is Saw) {
        _respawn();
      } else if (other is Checkpoint && fruitCount == 0) {
        _reachedCheckpoint();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    if (hasJumped && isOnGround) _playerJump(dt);
    if (velocity.y > _gravity * dt) isOnGround = false;
  }

  void _playerJump(double dt) {
    if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity * dt;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    bool isMoving = velocity.x != 0;
    bool isMovingLeftAndFacingRight = velocity.x < 0 && scale.x > 0;
    bool isMovingRightAndFacingLeft = velocity.x > 0 && scale.x < 0;
    bool isJumping = velocity.y < 0;
    bool isFalling = velocity.y > 0;

    if (isMovingRightAndFacingLeft || isMovingLeftAndFacingRight) {
      flipHorizontallyAroundCenter();
    }

    if (isMoving) playerState = PlayerState.running;
    if (isJumping) playerState = PlayerState.jump;
    if (isFalling) playerState = PlayerState.fall;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          } else if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
            break;
          }
        }
      }
    }
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.offsetY - hitbox.height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.offsetY - hitbox.height;
            isOnGround = true;
            break;
          } else if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _onLoadAllAnimations() {
    idleAnimation = _loadAnimation(PlayerState.idle);
    runningAnimation = _loadAnimation(PlayerState.running);
    doubleJumpAnimation = _loadAnimation(PlayerState.doubleJump);
    jumpAnimation = _loadAnimation(PlayerState.jump);
    wallJumpAnimation = _loadAnimation(PlayerState.wallJump);
    fallAnimation = _loadAnimation(PlayerState.fall);
    hitAnimation = _loadAnimation(PlayerState.hit, loop: false);
    spawningAnimation =
        _loadSpecialAnimation(PlayerState.spawning, loop: false);
    disappearingAnimation =
        _loadSpecialAnimation(PlayerState.disappearing, loop: false);

    // list of character animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.doubleJump: doubleJumpAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.spawning: spawningAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _loadAnimation(PlayerState state, {bool loop = true}) {
    String fileName = playerStateToImg[state]!;
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$fileName'),
        SpriteAnimationData.sequenced(
            amount: playerStateToImgCount[state]!,
            stepTime: stepTime,
            textureSize: Vector2.all(32),
            loop: loop));
  }

  SpriteAnimation _loadSpecialAnimation(PlayerState state, {bool loop = true}) {
    String fileName = playerStateToImg[state]!;
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$fileName'),
        SpriteAnimationData.sequenced(
            amount: playerStateToImgCount[state]!,
            stepTime: stepTime,
            textureSize: Vector2.all(96),
            loop: loop));
  }

  void _respawn() {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);

    gotHit = true;
    current = PlayerState.hit;
    final hitAnimation = animationTickers![PlayerState.hit];
    hitAnimation!.onComplete = () {
      position = startingPosition - Vector2.all(32);
      scale.x = 1;
      current = PlayerState.spawning;
      hitAnimation.reset();
      final spawningAnimation = animationTickers![PlayerState.spawning];
      spawningAnimation!.onComplete = () {
        gotHit = false;
        position = startingPosition;
        velocity = Vector2.zero();
        horizontalMovement = 0;
        _updatePlayerState();
        spawningAnimation.reset();
      };
    };
  }

  void _reachedCheckpoint() {
    if (game.playSounds) {
      FlameAudio.play('levelComplete.wav', volume: game.soundVolume);
    }

    _hasReachedCheckpoint = true;
    current = PlayerState.disappearing;

    // reposition disappering animation
    if (scale.x < 0) {
      position += Vector2(32, -32);
    } else if (scale.x > 0) {
      position -= Vector2.all(32);
    }

    final disappearingAnimation = animationTickers![PlayerState.disappearing];
    disappearingAnimation!.onComplete = () {
      position = Vector2.all(-640);

      Future.delayed(const Duration(seconds: 3), () {
        game.loadNextLevel();
      });
    };
  }
}
