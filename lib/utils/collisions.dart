import 'package:platformer/components/collision_block.dart';
import 'package:platformer/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  bool hasCollided = false;
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // checks if user is flipped
  final fixedX =
      player.scale.x < 0 ? playerX - hitbox.offsetX * 2 - playerWidth : playerX;
  // checks if its a platform to determine playerY position
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  hasCollided = fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX;

  return hasCollided;
}
