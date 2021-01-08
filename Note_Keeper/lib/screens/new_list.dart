import 'package:flutter/material.dart';
import 'package:flutter_app/screens/note_detail.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';


class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null){
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
     // backgroundColor: Colors.blueGrey,
      appBar: AppBar(

        title: Text('Notes'),

      ),

      body: notesListView(),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: () {
            debugPrint('Fab Clicked');
            navigateToDetail(Note('', '', 2, ''),'Add Note');
          }
          ),
    );
  }
  Widget notesListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position){
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getIconPriority(this.noteList[position].priority),
              ),
              title: Text(this.noteList[position].title, style: titleStyle),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                  child: Icon(Icons.delete, color: Colors.grey,),
                  onTap: (){
                    _delete(context, noteList[position]);
                  }),

              onTap: (){
                debugPrint('Listtile Tapped');
                navigateToDetail(this.noteList[position],'Edit note');
              },
            ),
          );
        }
    );
  }

  // Returns the priority color

  Color getPriorityColor (int priority) {
    switch (priority){
      case 1:
        return Colors.deepOrangeAccent;
        break;

      case 2:
        return Colors.lightGreenAccent;
        break;

      default:
        return Colors.lightGreenAccent;
    }
  }


  // Returns to priority icon

  Icon getIconPriority (int priority){
    switch (priority){
      case 1:
        return Icon(Icons.arrow_right) ;
        break;

      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default :
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context,Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar (context , "Note Deleted Successully");
      updateListView();
    }
  }

  void _showSnackBar (BuildContext context, String message){
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note,String title) async{
     bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
        return NoteDetail(note,title);
      }));
     if (result == true){
       updateListView();
     }
  }

  void updateListView(){

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database)  {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });


  }
}
