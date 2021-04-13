import 'package:flutter/material.dart';
import 'package:flutter_tasks/models/calendar_settings.dart';
import 'package:flutter_tasks/utilities/database_helper.dart';

class CalendarSettingsScreen extends StatefulWidget {
  final CalendarSettings calendarSettings;

  CalendarSettingsScreen(this.calendarSettings);

  @override
  State<StatefulWidget> createState() {
    return _CalendarSettingsState(this.calendarSettings);
  }
}

class _CalendarSettingsState extends State<CalendarSettingsScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;

  CalendarSettings calendarSettings;
  bool weekSwitch = false;

  _CalendarSettingsState(this.calendarSettings);

  // TODO - connect to database (does not currently do anything)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text('Calendar Settings'),
        ),
        body: SwitchListTile(
          title: Text("Start Week on Sunday"),
          value: weekSwitch,
          onChanged: (bool value) {
            setState(() {
              weekSwitch = value;
              calendarSettings.weekFirstDay = (weekSwitch) ? 1 : 0;
            });
          },
        ));
  }
}
