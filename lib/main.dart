import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'giris_ekrani.dart';

Future<void> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // Duplicate init durumunda mevcut app ile devam et
    if (e.code == 'duplicate-app') {
      // ignore, mevcut app kullanilacak
    } else {
      rethrow;
    }
  }
}

void main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Starting Firebase initialization...');
    print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');

    // Avoid hanging indefinitely on splash if initialization stalls
    const initTimeout = Duration(seconds: 5);
    try {
      await _ensureFirebaseInitialized().timeout(initTimeout);
      print('Firebase initialized successfully');
      print('Firebase app name: ${Firebase.app().name}');
      print('Firebase project ID: ${Firebase.app().options.projectId}');
    } on TimeoutException catch (_) {
      // Continue app startup; attempt background initialization
      print(
        'Firebase init timed out after ${initTimeout.inSeconds}s. Continuing startup...',
      );
      // Fire and forget
      _ensureFirebaseInitialized();
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        title: 'Kurye Uygulaması',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Firebase bağlantı hatası'),
                const SizedBox(height: 8),
                Text('$e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _ensureFirebaseInitialized();
                    } catch (_) {}
                    runApp(const MyApp());
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurye Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
