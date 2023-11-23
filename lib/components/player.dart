import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:platformer/components/collision_block.dart';
import 'package:platformer/pixel_adventure.dart';

enum PlayerState { idle, running, doubleJump, jump, wallJump, fall, hit }

const playerStateToImg = {
  PlayerState.idle: "Idle (32x32).png",
  PlayerState.running: "Run (32x32).png",
  PlayerState.doubleJump: "Double Jump (32x32).png",
  PlayerState.jump: "Jump (32x32).png",
  PlayerState.wallJump: "Wall Jump (32x32).png",
  PlayerState.fall: "Fall (32x32).png",
  PlayerState.hit: "Hit (32x32).png",
};
const playerStateToImgCount = {
  PlayerState.idle: 11,
  PlayerState.running: 12,
  PlayerState.doubleJump: 6,
  PlayerState.jump: 1,
  PlayerState.wallJump: 5,
  PlayerState.fall: 1,
  PlayerState.hit: 7,
};

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  final double stepTime = 0.05;
  late String character;
  Player({
    super.position,
    this.character = "Ninja Frog",
  });

  // animations
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation wallJumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _onLoadAllAnimations();
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    _updatePlayerState();

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

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    bool isMoving = velocity.x != 0;
    bool isMovingLeftAndFacingRight = velocity.x < 0 && scale.x > 0;
    bool isMovingRightAndFacingLeft = velocity.x > 0 && scale.x < 0;
    if (isMovingRightAndFacingLeft || isMovingLeftAndFacingRight) {
      flipHorizontallyAroundCenter();
    }

    if (isMoving) playerState = PlayerState.running;

    current = playerState;
  }

  void _onLoadAllAnimations() {
    idleAnimation = _loadAnimation(PlayerState.idle);
    runningAnimation = _loadAnimation(PlayerState.running);
    doubleJumpAnimation = _loadAnimation(PlayerState.doubleJump);
    jumpAnimation = _loadAnimation(PlayerState.jump);
    wallJumpAnimation = _loadAnimation(PlayerState.wallJump);
    fallAnimation = _loadAnimation(PlayerState.fall);
    hitAnimation = _loadAnimation(PlayerState.hit);

    // list of character animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.doubleJump: doubleJumpAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _loadAnimation(PlayerState state) {
    String fileName = playerStateToImg[state]!;
    return SpriteAnimation.fromFrameData(
        gameRef.images.fromCache('Main Characters/$character/$fileName'),
        SpriteAnimationData.sequenced(
            amount: playerStateToImgCount[state]!,
            stepTime: stepTime,
            textureSize: Vector2.all(32)));
  }
}
