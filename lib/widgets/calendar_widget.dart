// This widget uses Sfcalendar
// Source: https://pub.dev/packages/syncfusion_flutter_calendar

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/models/calendar_settings.dart';
import 'package:flutter_tasks/models/task.dart';
import 'package:flutter_tasks/models/task_region.dart';
import 'package:flutter_tasks/screens/calendar_settings.dart';
import 'package:flutter_tasks/utilities/database_helper.dart';
import 'package:flutter_tasks/utilities/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CalendarBoardState();
  }
}

class CalendarBoardState extends State<CalendarWidget> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  Utils utility = new Utils();
  final homeScaffold = GlobalKey<ScaffoldState>();

  List<Meeting> eventList; // TODO
  List<Meeting> taskList;
  List<TimeRegion> specialRegionsList;
  int count = 0;

  CalendarSettings calendarSettings; // TODO

  @override
  Widget build(BuildContext context) {
    bool updated = false;
    if (eventList == null) {
      eventList = List<Meeting>();
      updated = true;
    }
    if (taskList == null) {
      taskList = List<Meeting>();
      updated = true;
    }
    if (specialRegionsList == null) {
      specialRegionsList = List<TimeRegion>();
      updated = true;
    }
    if (calendarSettings == null) {
      calendarSettings = new CalendarSettings(0, 1);
    }
    if (updated) updateCalendarView();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Calendar',
            style: TextStyle(fontSize: 25),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarSettingsScreen(calendarSettings)),
                );
              },
            ),
          ],
        ),
        body: Container(
          child: SfCalendar(
            view: CalendarView.week, // TODO - Add setting to select default view
            showDatePickerButton: true,
            allowViewNavigation: true,
            allowedViews: <CalendarView>[
              CalendarView.day,
              CalendarView.week,
              CalendarView.workWeek,
              CalendarView.month,
              CalendarView.schedule
            ],
            selectionDecoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              shape: BoxShape.rectangle,
            ),
            firstDayOfWeek: calendarSettings.weekFirstDay,
            cellBorderColor: Colors.black38,
            specialRegions: specialRegionsList,
            dataSource: MeetingDataSource(_getDataSource()),
          ),
        ),
      ),
    );
  }

  void updateCalendarView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    // Add tasks
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getInCompleteTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = _getTasks(taskList);
          this.count = taskList.length;
        });
      });
    });

    // Add regions
    dbFuture.then((database) {
      Future<List<TaskRegion>> taskRegionListFuture = databaseHelper.getTaskRegionList();
      taskRegionListFuture.then((taskRegionList) {
        setState(() {
          this.specialRegionsList = _getSpecialRegions(taskRegionList);
          this.count = specialRegionsList.length;
        });
      });
    });
  }

  List<TimeRegion> _getSpecialRegions(List<TaskRegion> taskRegionList) {
    final List<TimeRegion> regions = <TimeRegion>[];

    for (int i = 0; i < taskRegionList.length; i++) {
      TaskRegion taskRegion = taskRegionList[i];

      DateTime startDate = utility.getDateTime(taskRegion.regionStartDate);
      TimeOfDay timeStart = utility.getTimeOfDay(taskRegion.regionStartTime);
      TimeOfDay timeEnd = utility.getTimeOfDay(taskRegion.regionEndTime);

      regions.add(TimeRegion(
        startTime: DateTime(startDate.year, startDate.month, startDate.day, timeStart.hour, timeStart.minute),
        endTime: DateTime(startDate.year, startDate.month, startDate.day, timeEnd.hour, timeEnd.minute),
        recurrenceRule: taskRegion.regionRRule,
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
        color: utility.getDimColor(taskRegion.regionColor),
        text: '${taskRegion.taskRegion}',
      ));
    }

    return regions;
  }

  // TODO - get Task due dates and put on calendar as all-day events?
  List<Meeting> _getTasks(List<Task> taskList) {
    final List<Meeting> taskMeetings = <Meeting>[];

    for (int i = 0; i < taskList.length; i++) {
      Task task = taskList[i];

      DateTime startDate = utility.getDateTime(task.date);
      TimeOfDay timeStart = utility.getTimeOfDay(task.time);
      TimeOfDay timeEnd = utility.getTimeOfDay(task.time);

      taskMeetings.add(Meeting(
        eventName: task.task + " DUE",
        from: DateTime(startDate.year, startDate.month, startDate.day, timeStart.hour, timeStart.minute),
        to: DateTime(startDate.year, startDate.month, startDate.day, timeEnd.hour, timeEnd.minute + 30),
        background: Colors.red,
        isAllDay: false, // true ?
      ));
    }

    return taskMeetings;
  }

  // fixme - move meetings to database
  // https://www.textmagic.com/free-tools/rrule-generator
  List<Meeting> _getDataSource() {
    eventList = <Meeting>[];

    final DateTime today = DateTime.now();

    /* EXAMPLES
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        eventName: 'Conference',
        from: DateTime(today.year, today.month, today.day, 9, 0, 0),
        to: DateTime(today.year, today.month, today.day, 9, 0, 0).add(const Duration(hours: 2)),
        background: Color(0xFF0F8644),
        isAllDay: false,
        recurrenceRule: 'FREQ=DAILY')
    ); */

    eventList.add(Meeting(
        eventName: 'Capstone',
        from: DateTime(today.year, today.month, 12, 8),
        to: DateTime(today.year, today.month, 12, 10),
        background: Colors.green,
        isAllDay: false,
        recurrenceRule:
            'FREQ=DAILY;BYDAY=SA,SU;INTERVAL=1;UNTIL=20210423T060000Z'));

    eventList.add(Meeting(
        eventName: 'Work',
        from: DateTime(today.year, today.month, 12, 10),
        to: DateTime(today.year, today.month, 12, 16),
        background: Colors.blue,
        isAllDay: false,
        recurrenceRule:
            'FREQ=WEEKLY;BYDAY=TU,TH;INTERVAL=1;UNTIL=20210423T060000Z'));

    return eventList + taskList;
  }
}

// TODO - move elsewhere ?
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments[index].recurrenceRule;
  }
}

class Meeting {
  Meeting(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.recurrenceRule});

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String recurrenceRule;
}
