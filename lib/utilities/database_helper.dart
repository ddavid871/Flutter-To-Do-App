import 'dart:io';

import 'package:flutter_tasks/utilities/strings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tasks/models/task.dart';

class DatabaseHelper {
  static final _databaseName = "tasks.db";
  static final _databaseVersion = 1;

  static final taskTable = 'task_table';

  static final colId = 'id';
  static final colTask = 'task';
  static final colDate = 'date';
  static final colTime = 'time';
  static final colEstTime = "estTime";
  static final colEstTimeHour = "estTimeHour";
  static final colEstTimeMinute = "estTimeMinute";
  static final colStatus = 'status';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store Database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "task.db";

    // Open/Create the database at the given path
    var taskDatabase =
    await openDatabase(path, version: 1, onCreate: _onCreate);

    return taskDatabase;
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $taskTable (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTask TEXT NOT NULL,
            $colDate TEXT,
            $colTime TEXT,
            $colEstTime TEXT,
            $colEstTimeHour INTEGER,
            $colEstTimeMinute INTEGER,
            $colStatus TEXT
          )
          ''');
  }

  // Fetch Operation: Get all Task objects from database
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await instance.database;
    //var result = await db.query(taskTable, orderBy: "$colId DESC");
    var result = db.query(taskTable, orderBy: '$colStatus, $colDate, $colTime');
    return result;
  }

  Future<List<Map<String, dynamic>>> getInCompleteTaskMapList() async {
    Database db = await instance.database;
    var result = db.rawQuery('SELECT * FROM $taskTable where $colStatus != "${Strings.taskCompleted}" order by $colDate, $colTime ASC');
    //var result = db.query(taskTable, orderBy: '$colStatus, $colDate, $colTime');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCompleteTaskMapList() async {
    Database db = await instance.database;
    var result = db.rawQuery('SELECT * FROM $taskTable where $colStatus = "${Strings.taskCompleted}" order by $colDate, $colTime ASC');
    //var result = db.query(taskTable, orderBy: '$colStatus, $colDate, $colTime');
    return result;
  }

  // Insert Operation: Insert a Task object to database
  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update a Task object and save it to database
  Future<int> updateTask(Task task) async {
    var db = await instance.database;
    var result = await db.update(taskTable, task.toMap(), where: '$colId = ?', whereArgs: [task.id] );
    return result;
  }

  // Delete Operation: Delete a Task object from database
  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete(taskTable, where: '$colId = ?', whereArgs: [id]);
  }

  // Get number of Task objects in database
  Future<int> getCount() async{
    Database db = await instance.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    // Get Map List from database
    var taskMapList = await getTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    // For loop to create Task List from a Map List
    for (int i=0; i<count; i++){
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  Future<List<Task>> getInCompleteTaskList() async {
    // Get Map List from database
    var taskMapList = await getInCompleteTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    //For loop to create Task List from a Map List
    for (int i = 0; i < count; i++){
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  Future<List<Task>> getCompleteTaskList() async {
    // Get Map List from database
    var taskMapList = await getCompleteTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    // For loop to create Task List from a Map List
    for (int i = 0; i < count; i++){
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $taskTable");
  }

}