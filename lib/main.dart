import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isFirebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseReady = true;
  } on UnsupportedError catch (e) {
    debugPrint('Firebase belum dikonfigurasi untuk platform ini: $e');
  }

  runApp(SiMikroApp(isFirebaseReady: isFirebaseReady));
}

class SiMikroApp extends StatelessWidget {
  const SiMikroApp({super.key, this.isFirebaseReady = false});

  final bool isFirebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiMikro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(isFirebaseReady: isFirebaseReady),
    );
  }
}
