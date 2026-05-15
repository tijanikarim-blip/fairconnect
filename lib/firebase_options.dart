import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTYAlMXzG5fHJD6Nx4w2OeM_1teXssuwc',
    appId: '1:83077177002:android:ee06e9ae1a20a119727ad3',
    messagingSenderId: '83077177002',
    projectId: 'expoconnect-8b7c4',
    storageBucket: 'expoconnect-8b7c4.firebasestorage.app',
  );
}
