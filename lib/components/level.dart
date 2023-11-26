import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:platformer/components/background_tile.dart';
import 'package:platformer/components/checkpoint.dart';
import 'package:platformer/components/chicken.dart';
import 'package:platformer/components/collision_block.dart';
import 'package:platformer/components/fruit.dart';
import 'package:platformer/components/player.dart';
import 'package:platformer/components/saw.dart';
import 'package:platformer/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final String levelName;
  final Player player;
  final Checkpoint checkpoint;
  List<CollisionBlock> collisionBlocks = [];

  Level({
    required this.levelName,
    required this.player,
    required this.checkpoint,
  });

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is Fruit && !child.isRemoved) {
      child.removed.whenComplete(() {
        player.fruitCount = max(player.fruitCount - 1, 0);
        if (player.fruitCount == 0) checkpoint.allFruitsCollected();
      });
    }
    super.onChildrenChanged(child, type);
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2.all(0),
      );
      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruitName = spawnPoint.name;
            final fruit = Fruit(
                name: fruitName,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            player.fruitCount += 1;
            break;
          case 'Saw':
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: !spawnPoint.properties.getValue('isHorizontal'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
            );
            add(saw);
            break;
          case 'Checkpoint':
            checkpoint.position = Vector2(spawnPoint.x, spawnPoint.y);
            checkpoint.size = Vector2(spawnPoint.width, spawnPoint.height);
            add(checkpoint);
          case 'Chicken':
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
            );
            add(chicken);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(
                  collision.width,
                  collision.height,
                ),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(
                  collision.width,
                  collision.height,
                ));
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
