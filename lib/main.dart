import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/secrets.dart';
import 'theme.dart';
import 'services/firebase_service.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: Secrets.firebaseApiKey,
        appId: Secrets.firebaseAppId,
        messagingSenderId: Secrets.firebaseMessagingSenderId,
        projectId: Secrets.firebaseProjectId,
        databaseURL: Secrets.firebaseDatabaseUrl,
      ),
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
    // Depending on platform, it might continue or fail here.
  }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FirebaseService()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const SafeNestApp(),
      ),
    );
  }
  
  class SafeNestApp extends StatelessWidget {
    const SafeNestApp({super.key});
  
    @override
    Widget build(BuildContext context) {
      final themeProvider = context.watch<ThemeProvider>();
      return MaterialApp(
        title: 'SafeNest',
        themeMode: themeProvider.themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      );
    }
  }
