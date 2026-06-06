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

  // 2. Fail-Safe Firebase Initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

  // 3. Initialize Services
  await NotificationService().initialize();

  // 4. Configure UI
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

class JITConnectApp extends ConsumerWidget {
  const JITConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'JIT Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
