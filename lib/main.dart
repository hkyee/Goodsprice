import 'package:flutter/material.dart';
import 'package:goodsprice/pages/scanResult.dart';
import 'package:goodsprice/pages/home.dart';
import 'package:goodsprice/pages/storeSelector.dart';
import 'package:goodsprice/pages/livescan.dart';
import 'package:goodsprice/services/databaseHelper.dart';
import 'package:camera/camera.dart';
import 'package:goodsprice/pages/checkPrice.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Initialize the database
  await DatabaseHelper.instance.database; // this will initialize the db

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(firstCamera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription firstCamera;
  const MyApp({super.key, required this.firstCamera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (BuildContext content) => home(),
        '/camera': (BuildContext context) => cameraScreen(camera: firstCamera),
        '/storeSelector': (BuildContext context) => storeSelector(),
        '/result': (BuildContext context) => scanResult(),
        '/checkPrice': (BuildContext context) => checkPrice(),
      },
    );
  }
}
