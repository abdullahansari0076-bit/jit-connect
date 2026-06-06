// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure the Flutter engine is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase ONLY if it hasn't been initialized yet
  // We check if Firebase.apps is empty (meaning no app is currently initialized)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // 3. Initialize other services
  await NotificationService().initialize();

  // 4. Configure System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Run the app
  runApp(const ProviderScope(child: JITConnectApp()));
}
