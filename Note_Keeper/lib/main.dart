import 'package:flutter/material.dart';
import 'package:flutter_app/screens/new_list.dart';
import 'package:flutter_app/screens/note_detail.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: NoteList(),
    );
  }
}
