import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:ntapp/screens/loadingscreen.dart';
import 'package:provider/provider.dart';
import 'package:ntapp/models/notesmodel.dart';
import 'package:firebase_ui_auth/src/providers/email_auth_provider.dart'
    as email_auth;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {},
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Welcome!"),
              backgroundColor: const Color(0xFFF7DA47),
              foregroundColor: Colors.black,
            ),
            body: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SignInScreen(providers: [
                    email_auth.EmailAuthProvider(),
                  ]);
                }

                final notesModel =
                    Provider.of<NotesModel>(context, listen: false);
                return LoadingScreen(
                    task: () async {
                      //  await Future.delayed(const Duration(seconds: 2));
                      return notesModel.loadFromCurrentUser();
                    }(),
                    landingPage: "/notes");
              },
            )));
  }
}
