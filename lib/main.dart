import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platformer/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // waits for flutter to be initialized
  await Flame.device.fullScreen(); // full screens the device
  await Flame.device.setLandscape(); // set ths screen to landscape

  PixelAdventure game = PixelAdventure();
  runApp(
    GameWidget(
        game: kDebugMode
            ? PixelAdventure()
            : game), // for reloading during development
  );
}
