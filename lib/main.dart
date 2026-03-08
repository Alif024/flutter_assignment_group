import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/asset_track_app.dart';
import 'package:flutter_assignment_group/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initializeAndSeed();
  runApp(const AssetTrackApp());
}
