import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/models/note.dart';


class DatabaseHelper {

  static DatabaseHelper _databaseHelper;   // Singleton DatabaseHelper
  static Database _database;               // Singleton Database

  String noteTable = 'note_table';
  String coltitle = 'title';
  String colId = 'id';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();  // Named Constructor to create Instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();     // This is Executed only once, Singleton Object
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if (_database == null){
      _database = await initializeDatabase();
    }
    return _database;

  }

  Future<Database> initializeDatabase () async{
    // Get the Directory Path For Android and iOS to Store Database

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Create/Open a Database at a given Path

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }


  void _createDb (Database db , int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT , $coltitle TEXT , '
        '$colDescription TEXT , $colPriority INTEGER , $colDate TEXT)');
  }



  // Fetch Operation: Get all Note Objects from Database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

   // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert Note Object to Database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable , note.toMap());
    return result;
  }

  // Update Operation
  Future<int> updatetNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable , note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }


  // Delete Operation
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }


  // Get number of Objects in Database

  Future<int> getCount () async {

    Database db = await this.database;
    List<Map<String, dynamic >>  x = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

// Get the 'Map list' [List<Map>] and to convert it to 'Note List'[List<Note>]

  Future<List<Note>> getNoteList () async {

    var noteMapList = await getNoteMapList();   // Get Maplist from Database
    int count = noteMapList.length;             // Count the number of Map entries in db table

    List <Note> noteList = List<Note>();
    // For Loop  to create a 'Note List' from a 'Map List'

    for (int i=0; i<count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));

    }
    return noteList;
  }

}







