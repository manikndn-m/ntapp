import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen(
      {super.key, required this.task, required this.landingPage});

  final Future<String?> task;
  final String landingPage;

  @override
  Widget build(BuildContext context) {
    task.then((error) {
      if (error == null) {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(landingPage);
      } else {
        return Center(child: Text("Error: $error"));
      }
    });

    return const Center(child: CircularProgressIndicator());
  }
}
