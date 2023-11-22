import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platformer/pixel_adventure.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // waits for flutter to be initialized
  Flame.device.fullScreen(); // full screens the device
  Flame.device.setLandscape(); // set ths screen to landscape

  PixelAdventure game = PixelAdventure();
  runApp(
    GameWidget(
        game: kDebugMode
            ? PixelAdventure()
            : game), // for reloading during development
  );
}
