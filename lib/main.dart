import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/simikro_store.dart';
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

class SiMikroApp extends StatefulWidget {
  const SiMikroApp({
    super.key,
    this.isFirebaseReady = false,
    this.store,
  });

  final bool isFirebaseReady;
  final SiMikroStore? store;

  @override
  State<SiMikroApp> createState() => _SiMikroAppState();
}

class _SiMikroAppState extends State<SiMikroApp> {
  late final SiMikroStore _store;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ?? SiMikroStore();
  }

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

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
      home: HomeScreen(
        store: _store,
        isFirebaseReady: widget.isFirebaseReady,
      ),
    );
  }
}
