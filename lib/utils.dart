import 'package:flutter/material.dart';

bool isLandscape(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return screenWidth > screenHeight;
}

Future<void> confirmationDialog(BuildContext context,
    {required String text,
    required void Function() onYes,
    required void Function() onNo}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(text),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onNo();
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}
