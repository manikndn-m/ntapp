import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  Note(
      {required this.id,
      required this.title,
      required this.content,
      required this.creationTime});

  String id, title, content;
  DateTime creationTime;
}

class NotesModel extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  // All these functions return null on success, or the error message (as string) if
  // the transaction failed.

  Future<String?> loadFromCurrentUser() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      List tempList = [];

      final snapshot =
          await FirebaseFirestore.instance.collection("$userId-notes").get();
      if (snapshot.docs.isNotEmpty) {
        tempList.addAll(snapshot.docs);
      }

      _notes.clear();
      for (var doc in snapshot.docs) {
        String creationTimeStr = doc.get("creationTime");
        final note = Note(
            id: doc.id,
            title: doc.get("title"),
            content: doc.get("content"),
            creationTime: DateTime.parse(creationTimeStr));
        _notes.add(note);
      }
      _notes.sort((n1, n2) => n1.creationTime.compareTo(n2.creationTime));
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}': ${e.message}";
    }

    return null;
  }

  Future<String?> createEmptyNote() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      var collection = FirebaseFirestore.instance.collection("$userId-notes");
      DateTime dt = DateTime.now();
      collection.add({
        "title": "",
        "content": "",
        "creationTime": dt.toString()
      }).then((value) {
        final id = value.id;
        final note = Note(id: id, title: "", content: "", creationTime: dt);
        _notes.add(note);
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}': ${e.message}";
    }

    return null;
  }

  Future<String?> deleteNote(String noteId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      var collection = FirebaseFirestore.instance.collection("$userId-notes");
      _notes.removeWhere((item) => item.id == noteId);
      collection.doc(noteId).delete().then((value) {});
      notifyListeners();
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}': ${e.message}";
    }

    return null;
  }

  Future<String?> saveNote(String noteId, String title, String content) async {
    try {
      final note = _notes.firstWhere((note) => note.id == noteId);
      note.title = title;
      note.content = content;

      final userId = FirebaseAuth.instance.currentUser!.uid;
      var collection = FirebaseFirestore.instance.collection("$userId-notes");
      collection
          .doc(noteId)
          .update({"title": title})
          .then((_) => print('Updated'))
          .catchError((error) => print('Update failed: $error'));
      collection
          .doc(noteId)
          .update({"content": content})
          .then((_) => print('Updated'))
          .catchError((error) => print('Update failed: $error'));

      notifyListeners();
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}': ${e.message}";
    }

    return null;
  }
}
