import 'package:flutter/material.dart';
import 'package:flutter_tasks/models/task_region.dart';
import 'package:flutter_tasks/utilities/database_helper.dart';
import 'package:flutter_tasks/utilities/strings.dart';
import 'package:flutter_tasks/utilities/utils.dart';
import 'package:flutter_tasks/models/task.dart';
import 'package:flutter_tasks/widgets/todo_widget.dart';

var globalDate = "Pick Date";

// ignore: must_be_immutable
class NewTask extends StatefulWidget {
  final String appBarTitle;
  final Task task;
  TodoState todoState;

  NewTask(this.task, this.appBarTitle, this.todoState);

  @override
  State<StatefulWidget> createState() {
    return TaskState(this.task, this.appBarTitle, this.todoState);
  }
}

class TaskState extends State<NewTask> {
  TodoState todoState;
  String appBarTitle;
  Task task;
  List<Widget> icons;
  List<String> regions;
  List<String> regionColors;

  TaskState(this.task, this.appBarTitle, this.todoState);

  bool marked = false;

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
    color: Colors.black,
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  Utils utility = new Utils();
  TextEditingController taskController = new TextEditingController();

  var formattedDate = "Pick Date";
  var formattedTime = "Select Time";
  var formattedEstTime = "Select Estimated Time";
  var selectedTaskRegion = Strings.noTaskRegion;
  var _minPadding = 10.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(minute: null, hour: null);

  @override
  void initState() {
    super.initState();
    regions = new List<String>();
    regions.add(Strings.noTaskRegion);

    regionColors = new List<String>();
    regionColors.add("");
  }

  @override
  Widget build(BuildContext context) {
    taskController.text = task.task;
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: new GestureDetector(
            child: Icon(Icons.close, size: 30),
            onTap: () {
              Navigator.pop(context);
              todoState.updateListView();
            },
          ),
          title: Text(appBarTitle, style: TextStyle(fontSize: 25)),
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                  hintText: "Insert Task Title",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: TextStyle(
                      fontSize: 18,
                      fontFamily: "Lato",
                      fontStyle: FontStyle.italic,
                      color: Colors.grey)),
              onChanged: (value) {
                updateTask();
              },
            ),
          ), // Task Title
          Padding(
              padding: EdgeInsets.only(left: 0),
              child: _isEditable()
                  ? CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text("Mark as Done", style: titleStyle),
                      value: (task.status == Strings.taskCompleted)
                          ? true
                          : marked,
                      onChanged: (bool value) {
                        setState(() {
                          marked = value;
                          task.status =
                              "ETC: ${task.estTime}"; // TODO - % complete
                        });
                      })
                  : Container(
                      height: 2,
                    )), // Mark as Done
          ListTile(
            title: task.date.isEmpty
                ? Text(
                    "Pick Date",
                    style: titleStyle,
                  )
                : Text(task.date),
            subtitle: Text("Due Date"),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              var pickedDate = await utility.selectDate(context, task.date);
              if (pickedDate != null && pickedDate.isNotEmpty)
                setState(() {
                  this.formattedDate = pickedDate.toString();
                  task.date = formattedDate;
                });
            },
          ), // Due Date
          ListTile(
            title: task.time.isEmpty
                ? Text(
                    "Select Time",
                    style: titleStyle,
                  )
                : Text(task.time),
            subtitle: Text("Time Due"),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              var pickedTime = await utility.selectTime(context, task.time);
              if (pickedTime != null && pickedTime.isNotEmpty)
                setState(() {
                  formattedTime = pickedTime;
                  task.time = formattedTime;
                });
            },
          ), // Select Time
          ListTile(
            title: task.estTime.isEmpty
                ? Text(
                    "Select Estimated Time",
                    style: titleStyle,
                  )
                : Text(task.estTime),
            subtitle: Text("Estimated Time to Complete"),
            trailing: Icon(Icons.timelapse),
            onTap: () async {
              var pickedEstTime = await utility.selectEstTime(
                  context, task.estTimeHour, task.estTimeMinute);
              if (pickedEstTime != null && pickedEstTime.isNotEmpty)
                setState(() {
                  formattedEstTime = pickedEstTime["estTime"];
                  task.estTime = pickedEstTime["estTime"];
                  task.estTimeHour = int.parse(pickedEstTime["estTimeHour"]);
                  task.estTimeMinute =
                      int.parse(pickedEstTime["estTimeMinute"]);
                });
            },
          ), // Select Estimated Time
          FutureBuilder<List>(
            future: _getTaskRegions(regions),
            builder: (context, snapshot) {
              return ListTile(
                // https://api.flutter.dev/flutter/material/DropdownButton-class.html
                title: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: task.taskRegion.isEmpty
                            ? selectedTaskRegion
                            : task.taskRegion,
                        style: titleStyle,
                        onChanged: (String value) {
                          setState(() {
                            this.selectedTaskRegion = value;
                            task.taskRegion = value;
                            task.taskRegionColor = regionColors[regions.indexOf(value)];
                          });
                        },
                        items: snapshot.data?.map((taskRegion) {
                              return DropdownMenuItem<String>(
                                value: taskRegion,
                                child: Text(taskRegion, style: titleStyle),
                              );
                            })?.toList() ??
                            // Holding container while the taskRegionList is null during retrieval
                            <String>[ // Checks to avoid duplicate string while waiting
                              (task.taskRegion.isEmpty) ? Strings.noTaskRegion : task.taskRegion
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: titleStyle),
                              );
                            }).toList())),
                subtitle: Text("Related Task Region"),
                trailing: Icon(Icons.auto_awesome_mosaic),
              );
            },
          ), // Related Task Region
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.all(_minPadding / 2),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              elevation: 3.0,
              child: Text(
                "Save",
                style: buttonStyle,
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
              onPressed: () {
                setState(() {
                  _save();
                });
              },
            ),
          ), // Save Button
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: _isEditable()
                ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    padding: EdgeInsets.all(_minPadding / 2),
                    color: Colors.grey,
                    textColor: Colors.black,
                    elevation: 3.0,
                    child: Text(
                      "Delete",
                      style: buttonStyle,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.2,
                    ),
                    onPressed: () {
                      setState(() {
                        _delete();
                      });
                    },
                  )
                : Container(),
          ) // Delete Button
        ]));
  }

  void markedDone() {}

  bool _isEditable() {
    if (this.appBarTitle == Strings.addTask)
      return false;
    else {
      return true;
    }
  }

  void updateTask() {
    task.task = taskController.text;
  }

  Future<List<String>> _getTaskRegions(var regions) async {
    var taskRegionList = await databaseHelper.getTaskRegionList();

    for (int i = 0; i < taskRegionList.length; i++) {
      String region = taskRegionList[i].taskRegion;
      if (!regions.contains(region)) {
        regions.add(taskRegionList[i].taskRegion);
        this.regionColors.add(taskRegionList[i].regionColor);
      }
    }

    return regions;
  }

  // InputConstraints
  bool _checkNotNull() {
    bool res;
    if (taskController.text.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please input a Task title.');
      res = false;
    } else if (task.date.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please select a Date.');
      res = false;
    } else if (task.time.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please select a Time.');
      res = false;
    } else if (task.estTime.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please input an Estimated Time.');
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  // Save data
  void _save() async {
    int result;
    task.status = "ETC: ${task.estTime}"; // TODO - maybe put in % completed?
    if (_isEditable() && marked) {
      task.status = Strings.taskCompleted;
    }
    //task.task = taskController.text;
    //task.date = formattedDate;

    if (_checkNotNull() == true) {
      if (task.id != null) {
        // Update Operation
        result = await databaseHelper.updateTask(task);
      } else {
        // Insert Operation
        result = await databaseHelper.insertTask(task);
      }

      todoState.updateListView();

      Navigator.pop(context);

      if (result != 0) {
        utility.showAlertDialog(context, 'Status', 'Task saved successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem saving task.');
      }
    }
  }

  void _delete() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this task?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await databaseHelper.deleteTask(task.id);
                  todoState.updateListView();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  utility.showSnackBar(
                      scaffoldKey, 'Task Deleted Successfully.');
                },
                child: Text("Yes"),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          );
        });
  }
}
