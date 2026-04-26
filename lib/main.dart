import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'services/firebase_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Attempting to initialize Firebase.
    // If you are running on Web or iOS, you may need to pass FirebaseOptions explicitly here,
    // or ensure google-services.json / GoogleService-Info.plist is present.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDQmyJHTeWHtorit6UJ1tT_EL1tqUtpyLk",
        appId: "1:245100657388:android:5591c28c89423984", // Generic looking ID
        messagingSenderId: "245100657388",
        projectId: "safenest-6ae41",
        databaseURL: "https://safenest-6ae41-default-rtdb.asia-southeast1.firebasedatabase.app/",
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
      ],
      child: const SafeNestApp(),
    ),
  );
}

class SafeNestApp extends StatelessWidget {
  const SafeNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeNest',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
