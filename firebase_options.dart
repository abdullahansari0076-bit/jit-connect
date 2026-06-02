// File generated based on your Firebase project: jit-connect-3f971
// DO NOT modify this file manually

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwlAjOLGlnQqL8x6dOOBvHHugzXjTmctU',
    appId: '1:328982535563:android:092cb0d7f65e410851238e',
    messagingSenderId: '328982535563',
    projectId: 'jit-connect-3f971',
    storageBucket: 'jit-connect-3f971.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwlAjOLGlnQqL8x6dOOBvHHugzXjTmctU',
    appId: '1:328982535563:android:092cb0d7f65e410851238e',
    messagingSenderId: '328982535563',
    projectId: 'jit-connect-3f971',
    storageBucket: 'jit-connect-3f971.appspot.com',
    iosClientId: 'com.jit.jitconnect',
    iosBundleId: 'com.jit.jitconnect',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwlAjOLGlnQqL8x6dOOBvHHugzXjTmctU',
    appId: '1:328982535563:android:092cb0d7f65e410851238e',
    messagingSenderId: '328982535563',
    projectId: 'jit-connect-3f971',
    storageBucket: 'jit-connect-3f971.appspot.com',
    authDomain: 'jit-connect-3f971.firebaseapp.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwlAjOLGlnQqL8x6dOOBvHHugzXjTmctU',
    appId: '1:328982535563:android:092cb0d7f65e410851238e',
    messagingSenderId: '328982535563',
    projectId: 'jit-connect-3f971',
    storageBucket: 'jit-connect-3f971.appspot.com',
    iosClientId: 'com.jit.jitconnect',
    iosBundleId: 'com.jit.jitconnect',
  );
}
