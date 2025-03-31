import 'package:flutter/material.dart';
import 'package:goodsprice/pages/home.dart';
import 'package:goodsprice/pages/camera.dart';
import 'package:goodsprice/pages/storeSelector.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (BuildContext context) => home(),
      '/camera': (BuildContext context) => camera(),
      '/storeSelector': (BuildContext context) => storeSelector(),
    },
  ));
}
