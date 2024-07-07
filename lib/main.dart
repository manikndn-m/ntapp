import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:ntapp/models/notesmodel.dart';
import 'package:ntapp/screens/notesscreen.dart';
import 'firebase_options.dart';
import 'screens/loginscreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

  runApp(ChangeNotifierProvider(
      create: (context) => NotesModel(),
      child: MaterialApp(
          title: 'Note taking app',
          theme: ThemeData(
            useMaterial3: false,
            primaryColor: const Color(0xFF151026),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/notes': (context) => const NotesScreen(),
          },
          home: const LoginScreen())));
}
