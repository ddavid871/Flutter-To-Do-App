import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tasks/models/task_region.dart';
import 'package:flutter_tasks/utilities/database_helper.dart';
import 'package:flutter_tasks/utilities/strings.dart';
import 'package:flutter_tasks/utilities/utils.dart';
import 'package:flutter_tasks/widgets/region_widget.dart';

var globalDate = "Pick Date";

// ignore: must_be_immutable
class NewTaskRegion extends StatefulWidget {
  final String appBarTitle;
  final TaskRegion taskRegion;
  RegionState regionState;

  NewTaskRegion(this.taskRegion, this.appBarTitle, this.regionState);

  @override
  State<StatefulWidget> createState() {
    return TaskRegionState(this.taskRegion, this.appBarTitle, this.regionState);
  }
}

class TaskRegionState extends State<NewTaskRegion> {
  RegionState regionState;
  String appBarTitle;
  TaskRegion taskRegion;

  List<Widget> icons;

  TaskRegionState(this.taskRegion, this.appBarTitle, this.regionState);

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseHelper helper = DatabaseHelper.instance;
  Utils utility = new Utils();
  TextEditingController itemTitleController = new TextEditingController();

  var regionStartDate = "Pick Date";
  var regionStartTime = "Pick Start Time";
  var regionEndTime = "Pick End Time";
  var repeatRule = "";
  var regionColor = "";
  var _minPadding = 10.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(minute: null, hour: null);

  @override
  Widget build(BuildContext context) {
    itemTitleController.text = taskRegion.taskRegion;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: new GestureDetector(
          child: Icon(Icons.close, size: 30),
          onTap: () {
            Navigator.pop(context);
            regionState.updateListView();
          },
        ),
        title: Text(appBarTitle, style: TextStyle(fontSize: 25)),
      ),
      body: Container(
          child: ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(_minPadding),
          child: TextField(
            controller: itemTitleController,
            decoration: InputDecoration(
                hintText: "Insert Task Region Title",
                hintStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: "Lato",
                    fontStyle: FontStyle.italic,
                    color: Colors.grey)),
            onChanged: (value) {
              updateTaskRegion();
            },
          ),
        ),
        // Task Region Title
        ListTile(
          title: taskRegion.regionStartDate.isEmpty
              ? Text(
                  "Pick Date",
                  style: titleStyle,
                )
              : Text(taskRegion.regionStartDate),
          subtitle: Text("Start Date"),
          trailing: Icon(Icons.calendar_today),
          onTap: () async {
            var pickedStartDate =
                await utility.selectDate(context, taskRegion.regionStartDate);
            if (pickedStartDate != null && pickedStartDate.isNotEmpty)
              setState(() {
                this.regionStartDate = pickedStartDate.toString();
                taskRegion.regionStartDate = regionStartDate;
              });
          },
        ),
        // Task Region Start Date
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Expanded(
            child: ListTile(
              title: taskRegion.regionStartTime.isEmpty
                  ? Text(
                      "Pick Start Time",
                      style: titleStyle,
                    )
                  : Text(taskRegion.regionStartTime),
              subtitle: Text("Start Time"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                var pickedStartTime = await utility.selectTime(
                    context, taskRegion.regionStartTime);
                if (pickedStartTime != null && pickedStartTime.isNotEmpty)
                  setState(() {
                    this.regionStartTime = pickedStartTime.toString();
                    taskRegion.regionStartTime = regionStartTime;
                  });
              },
            ),
          ),
          Expanded(
            child: ListTile(
              title: taskRegion.regionEndTime.isEmpty
                  ? Text(
                      "Pick End Time",
                      style: titleStyle,
                    )
                  : Text(taskRegion.regionEndTime),
              subtitle: Text("End Time"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                var pickedEndTime =
                    await utility.selectTime(context, taskRegion.regionEndTime);
                if (pickedEndTime != null && pickedEndTime.isNotEmpty)
                  setState(() {
                    this.regionEndTime = pickedEndTime.toString();
                    taskRegion.regionEndTime = regionEndTime;
                  });
              },
            ),
          ),
        ]),
        // Task Region Start/End Time
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
        ),
        // Save Button
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
        )
        // Delete Button
      ])), // Add Task Region
    );
  }

  bool _isEditable() {
    if (this.appBarTitle == Strings.addTaskRegion)
      return false;
    else {
      return true;
    }
  }

  void updateTaskRegion() {
    taskRegion.taskRegion = itemTitleController.text;
  }

  // Input Constraints
  bool _checkNotNull() {
    bool res;
    if (itemTitleController.text.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please input a Task Region title.');
      res = false;
    } else if (taskRegion.regionStartDate.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please select a Date.');
      res = false;
    } else if (taskRegion.regionStartTime.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please select a Start Time.');
      res = false;
    } else if (taskRegion.regionEndTime.isEmpty) {
      utility.showSnackBar(scaffoldKey, 'Please select an End Time.');
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  // Start/End Time Input Constraints
  bool _checkTimeGap() {
    bool res;
    DateTime now = DateTime.now();
    TimeOfDay timeStart = utility.getTimeOfDay(taskRegion.regionStartTime);
    TimeOfDay timeEnd = utility.getTimeOfDay(taskRegion.regionEndTime);

    DateTime regionStart = DateTime(
        now.year, now.month, now.day, timeStart.hour, timeStart.minute);
    DateTime regionEnd =
        DateTime(now.year, now.month, now.day, timeEnd.hour, timeEnd.minute);

    if (regionEnd.isBefore(regionStart) || (regionEnd == regionStart)) {
      utility.showSnackBar(scaffoldKey,
          'Please select an End Time that is after the Start Time.');
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  // Save data
  void _save() async {
    int result;

    if (_checkNotNull() && _checkTimeGap()) {
      if (taskRegion.id != null) {
        // Update Operation
        result = await helper.updateTaskRegion(taskRegion);
      } else {
        // Insert Operation
        result = await helper.insertTaskRegion(taskRegion);
      }

      regionState.updateListView();

      Navigator.pop(context);

      if (result != 0) {
        utility.showAlertDialog(
            context, 'Status', 'Task Region saved successfully.');
      } else {
        utility.showAlertDialog(
            context, 'Status', 'Problem saving task region.');
      }
    }
  }

  void _delete() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this task region?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await helper.deleteTaskRegion(taskRegion.id);
                  regionState.updateListView();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  utility.showSnackBar(
                      scaffoldKey, 'Task Region Deleted Successfully.');
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
