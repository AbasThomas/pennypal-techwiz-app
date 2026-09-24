import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Centralises Firebase startup so every feature can show a useful setup error.
/// Run `flutterfire configure` before release to add platform Firebase options.
class FirebaseBootstrap {
  static bool ready = false;
  static String? error;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      ready = true;
    } catch (e) {
      error = 'Firebase is not configured yet. Run flutterfire configure.';
    }
  }
}
