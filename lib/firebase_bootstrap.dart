import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_assignment_group/data/firestore_seeder.dart';
import 'package:flutter_assignment_group/firebase_options.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initializeAndSeed() async {
    if (!_supportsFirebaseOnCurrentPlatform) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      await FirestoreSeeder.seedIfNeeded();
    } catch (error) {
      debugPrint('Firestore seed skipped: $error');
    }
  }

  static bool get _supportsFirebaseOnCurrentPlatform {
    return kIsWeb || defaultTargetPlatform == TargetPlatform.android;
  }
}
