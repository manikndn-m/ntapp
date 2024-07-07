import 'package:flutter/material.dart';
import 'package:ntapp/models/notesmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntapp/utils.dart';
import 'dart:io';

class _NotePanel extends StatefulWidget {
  const _NotePanel(
      {required this.id,
      required this.title,
      required this.content,
      required this.creationTime});

  final String id, title, content;
  final DateTime creationTime;

  @override
  State<_NotePanel> createState() => _NotePanelState();
}

class _NotePanelState extends State<_NotePanel> {
  bool _editMode = false;
  late FocusNode _titleInputFocusNode;

  TextEditingController _titleInputController = TextEditingController(),
      _contentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleInputController = TextEditingController(text: widget.title);
    _contentInputController = TextEditingController(text: widget.content);
    _titleInputFocusNode = FocusNode();
  }

  Widget buildButton(void Function()? onPressed, IconData icon) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: const Color.fromARGB(255, 41, 177, 187),
          size: 30.0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    _titleInputController.text = widget.title;
    _contentInputController.text = widget.content;

    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
        width: 100,
        child: Column(children: [
          Container(
              width: double.infinity,
              color: const Color(0xFFFFE306),
              child: Center(
                  child: _editMode
                      ? TextField(
                          controller: _titleInputController,
                          maxLines: 1,
                          focusNode: _titleInputFocusNode,
                          style: const TextStyle(fontSize: 20),
                          decoration: const InputDecoration.collapsed(
                              hintText: 'Title'),
                        )
                      : Text(widget.title,
                          style: const TextStyle(fontSize: 20)))),
          Container(
              width: double.infinity,
              height: widget.content == "" ? 60 : null,
              color: const Color.fromARGB(255, 243, 228, 117),
              child: _editMode
                  ? Center(
                      child: TextField(
                      controller: _contentInputController,
                      maxLines: 6,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.multiline,
                      decoration:
                          const InputDecoration.collapsed(hintText: 'Content'),
                    ))
                  : (widget.title == "" && widget.content == "")
                      ? const Center(
                          child: Text("tap the pencil icon to edit",
                              style: TextStyle(
                                  color: Color.fromARGB(158, 31, 30, 30))))
                      : Padding(
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          child: Text(widget.content,
                              style: const TextStyle(fontSize: 20)))),
          SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(children: [
                  _editMode == false
                      ? buildButton(() {
                          setState(() {
                            _editMode = true;
                            _titleInputFocusNode.requestFocus();
                          });
                        }, Icons.edit)
                      : buildButton(() {
                          setState(() {
                            _editMode = false;
                            final notesModel =
                                Provider.of<NotesModel>(context, listen: false);
                            notesModel.saveNote(
                                widget.id,
                                _titleInputController.text,
                                _contentInputController.text);
                          });
                        }, Icons.save),
                  buildButton(() {
                    confirmationDialog(context,
                        text: 'Are you sure you want to delete that note?',
                        onYes: () {
                      Provider.of<NotesModel>(context, listen: false)
                          .deleteNote(widget.id);
                    }, onNo: () {});
                  }, Icons.delete),
                  Text(DateFormat("dd-MM-yyyy h:m a")
                      .format(widget.creationTime)
                      .toString()),
                ]),
              ))
        ]));
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _scrollController = ScrollController();
  bool _scrollToBottom = false;

  void logoutPrompt() {
    final accountEmail = FirebaseAuth.instance.currentUser!.email!;
    confirmationDialog(context,
        text: 'Are you sure you want to logout $accountEmail?', onYes: () {
      Navigator.of(context).pop();
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamed("/login");
    }, onNo: () {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double notePanelWidth =
        isLandscape(context) ? screenWidth * 0.4 : screenWidth * 0.9;

    if (_scrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      });

      _scrollToBottom = false;
    }

    final notesModel = Provider.of<NotesModel>(context);
    final notes = notesModel.notes;

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          Navigator.pop(context);
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Note taking app"),
              backgroundColor: const Color.fromRGBO(247, 218, 71, 1),
              foregroundColor: Colors.black,
              actions: <Widget>[
                PopupMenuButton<void Function()>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: () => logoutPrompt(),
                        child: const Text("Logout"),
                      ),
                      PopupMenuItem(
                        value: () => exit(0),
                        child: const Text("Exit"),
                      ),
                    ];
                  },
                  onSelected: (fn) => fn(),
                ),
              ],
            ),
            body: notes.isEmpty
                ? const Center(
                    child: Text("Tap the add button to create a new note"))
                : Center(
                    child: SizedBox(
                        width: notePanelWidth,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(20.0),
                            controller: _scrollController,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return _NotePanel(
                                  id: note.id,
                                  title: note.title,
                                  content: note.content,
                                  creationTime: note.creationTime);
                            })),
                  ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  notesModel.createEmptyNote();
                  _scrollToBottom = true;
                },
                backgroundColor: const Color.fromARGB(255, 41, 177, 187),
                child: const Icon(Icons.add))));
  }
}
