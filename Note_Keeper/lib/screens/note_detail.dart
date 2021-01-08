import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note,this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ["High","Low"];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState (this.note,this.appBarTitle);
  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: (){
        // Control Things when user press Back button
        moveToLastScreen();
      },

      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: (){
              moveToLastScreen();

              }
          ),

          title: Text('Edit Note'),

        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: noteDetailListView(),
        ),
      ),
    );
  }
  Widget noteDetailListView(){
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return ListView(
      children: <Widget>[
        // First Element
        ListTile(
          title: DropdownButton(
              items: _priorities.map((String dropDownStringItems) => DropdownMenuItem<String>(
                  value: dropDownStringItems,
                  child: Text(dropDownStringItems),
              ),
              ).toList(),
              
              value: getPriorityAsString(note.priority),

              onChanged: (value){
                setState(() {
                  debugPrint('User selected $value ');
                  updatePriorityAsInt(value);
                });
              }),
        ),

        // Second Element
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: titleController,
            onChanged: (value){
                debugPrint('Textfield');
                updateTitle();
            },
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),

        // Third Element
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: descriptionController,
            onChanged: (value){
              debugPrint('Description');
              updateDescription();
            },
            decoration: InputDecoration(
              labelText: 'Description',

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
        
        // Fourth Element
        
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  textColor: Theme.of(context).primaryColorLight,
                  child: Text('Save', textScaleFactor: 1.3),
                    onPressed: (){
                      setState(() {
                        debugPrint('');
                        _save();
                      });
                    },
                ),
              ),

              Container(width: 10.0,),

              Expanded(
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  textColor: Theme.of(context).primaryColorLight,
                  child: Text('Delete', textScaleFactor: 1.3),
                  onPressed: (){
                    setState(() {
                      debugPrint('Delete Button Clicked');
                      _delete();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        

      ],
    );
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to database

  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert the Integer priority into String priority and Display it to user in DropDown

  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1 :
        priority = _priorities[0];    // 'High'
        break;
      case 2:
        priority = _priorities[1];    // 'Low'
        break;
    } return priority;
  }

  // Update the Title of Note Object

  void updateTitle(){
    note.title = titleController.text;
  }

  // Update the Description of Note Object

  void updateDescription (){
    note.description = descriptionController.text;
  }

  // Save data to database

  void _save () async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null){ // Case 1: Update Operation
      result = await helper.updatetNote(note);
    } else{               // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }
    if (result != 0){ // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {          // Failure
      _showAlertDialog('Stayus', 'Problem Saving Note');
    }

  }

  void _delete () async {

    moveToLastScreen();
    // Case 1: If the User is trying to delete the NEW NOTE

    if(note.id == null){
      _showAlertDialog('Status', 'No Note was Deleted');
      return;
    }

    // Case 2: If the User is trying to delete the OLD NOTE with id
    int result = await helper.deleteNote(note.id);
    if (result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Stayus', 'Error occured while Deleting Note');
    }



  }

  void _showAlertDialog (String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context:  context,
      builder: (_) => alertDialog,
    );
  }

}
