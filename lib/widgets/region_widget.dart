import 'package:flutter/material.dart';
import 'package:flutter_tasks/models/task_region.dart';
import 'package:flutter_tasks/screens/new_task_region.dart';
import 'package:flutter_tasks/utilities/database_helper.dart';
import 'package:flutter_tasks/utilities/strings.dart';
import 'package:flutter_tasks/utilities/utils.dart';
import 'package:flutter_tasks/widgets/region_list_widget.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_tasks/widgets/task_list_widget.dart';

class RegionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegionState();
  }
}

class RegionState extends State<RegionWidget> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  Utils utility = new Utils();
  final homeScaffold = GlobalKey<ScaffoldState>();

  List<TaskRegion> taskRegionsList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (taskRegionsList == null) {
      taskRegionsList = List<TaskRegion>();
      updateListView();
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Task Regions',
              style: TextStyle(fontSize: 25),
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                    future: databaseHelper.getTaskRegionList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Text("Loading . . . ");
                      } else {
                        if (snapshot.data.length < 1) {
                          return Center(
                            child: Text(
                              'No Task Regions Added',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int position) {
                              return new GestureDetector(
                                  onTap: () {
                                    navigateToTaskRegion(
                                        snapshot.data[position],
                                        "Edit Task Region",
                                        this);
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(1.0),
                                    elevation: 2.0,
                                    child: RegionListWidget(
                                      title: snapshot.data[position].taskRegion,
                                      sub1: snapshot.data[position].regionRRuleOption,
                                      sub2:
                                          "${snapshot.data[position].regionStartTime}–${snapshot.data[position].regionEndTime}",
                                      color: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Container(
                                          height: 10.0,
                                          width: 10.0,
                                          color: utility.getColor(snapshot.data[position].regionColor),
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                        size: 28,
                                      ),
                                    ),
                                  ));
                            });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              tooltip: "Add Item",
              child: Icon(Icons.add),
              onPressed: () {
                navigateToTaskRegion(
                    TaskRegion('', '', '', '', '', '', ''), Strings.addTaskRegion, this);
              }),
        ));
  }

  void navigateToTaskRegion(
      TaskRegion taskRegion, String title, RegionState obj) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewTaskRegion(taskRegion, title, obj)),
    );
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    dbFuture.then((database) {
      Future<List<TaskRegion>> taskRegionListFuture =
          databaseHelper.getTaskRegionList();
      taskRegionListFuture.then((taskRegionsList) {
        setState(() {
          this.taskRegionsList = taskRegionsList;
          this.count = taskRegionsList.length;
        });
      });
    });
  }

  void delete(int id) async {
    await databaseHelper.deleteTaskRegion(id);
    updateListView();
    utility.showSnackBar(homeScaffold, 'Task Region Deleted Successfully');
  }
}
