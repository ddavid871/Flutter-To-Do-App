import 'package:flutter/material.dart';
import 'package:flutter_tasks/utilities/time_input.dart';
import 'package:flutter_tasks/utilities/est_time_picker.dart';
import 'package:intl/intl.dart';

class Utils {
  static Utils _utils;

  Utils._createInstance();

  factory Utils() {
    if (_utils == null) {
      _utils = Utils._createInstance();
    }
    return _utils;
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void showSnackBar(var scaffoldKey, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1, milliseconds: 500),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<String> selectDate(BuildContext context, String date) async {
    final DateTime picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialDate: date.isEmpty
            ? DateTime.now()
            : new DateFormat("d MMM, y").parse(date),
        lastDate: DateTime.now().add(Duration(days: 356)));
    if (picked != null) return formatDate(picked);

    return "";
  }

  Future<String> selectTime(BuildContext context, String taskTime) async {
    int taskTimeHour, taskTimeMinutes;
    var taskPeriod;
    if (taskTime.isNotEmpty) {
      var taskTimePieces = taskTime.split(RegExp(":| "));
      taskTimeHour = int.parse(taskTimePieces[0]);
      taskTimeMinutes = int.parse(taskTimePieces[1]);
      taskPeriod = taskTimePieces[2];
      if (taskPeriod == "PM") {
        taskTimeHour = taskTimeHour + 12;
      }
    }

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: taskTime.isEmpty
        ? TimeOfDay(hour: 12, minute: 0)
        : new TimeOfDay(hour: taskTimeHour, minute: taskTimeMinutes),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (picked != null) {
      return timeFormat(picked);
    }

    return "";
  }

  Future<Map<String, String>> selectEstTime(BuildContext context, int estTimeHour, int estTimeMinute) async {
    Map estTimePieces = new Map<String, String>();

    int eHour = (estTimeHour == null) ? 1 : estTimeHour;
    int eMinute = (estTimeMinute == null)  ? 0 : estTimeMinute;

    final TimeInput picked = await showEstTimePicker(
      context: context,
      initialTime: TimeInput(hour: eHour, minute: eMinute),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child,
        );
      },
    );

    if (picked != null) {
      estTimePieces.update(
        "estTime",
        (dynamic val) => estTimeFormat(picked),
        ifAbsent: () => estTimeFormat(picked),
      );
      estTimePieces.update(
        "estTimeHour",
        (dynamic val) => picked.hour.toString(),
        ifAbsent: () => picked.hour.toString(),
      );
      estTimePieces.update(
        "estTimeMinute",
        (dynamic val) => picked.minute.toString(),
        ifAbsent: () => picked.minute.toString(),
      );
    }

    return estTimePieces;
  }

  String timeFormat(TimeOfDay picked) {
    var hour = 00;
    var time = "PM";
    if (picked.hour >= 12) {
      time = "PM";
      if (picked.hour > 12) {
        hour = picked.hour - 12;
      } else if (picked.hour == 00) {
        hour = 12;
      } else {
        hour = picked.hour;
      }
    } else {
      time = "AM";
      if (picked.hour == 00) {
        hour = 12;
      } else {
        hour = picked.hour;
      }
    }
    var h, m;
    if (hour % 100 < 10) {
      h = "0" + hour.toString();
    } else {
      h = hour.toString();
    }

    int minute = picked.minute;
    if (minute % 100 < 10)
      m = "0" + minute.toString();
    else
      m = minute.toString();

    return h + ":" + m + " " + time;
  }

  String formatDate(DateTime selectedDate) =>
      new DateFormat("d MMM, y").format(selectedDate);

  String estTimeFormat(TimeInput picked) {
    var hourValue = "${picked.hour} hour";
    var minValue = "${picked.minute} minute";

    if (picked.hour == 0) { // Only returns minutes
      if (picked.minute == 1) {
        return "$minValue";
      }
      return "${minValue}s";
    } else if (picked.hour == 1) {
      if (picked.minute == 0) { // Checks for singular vs. plural
        return hourValue;
      } else if (picked.minute == 1) {
        return "$hourValue, $minValue";
      }
      return "$hourValue, ${minValue}s";
    }
    else { // picked.hour > 1
      if (picked.minute == 0) { // Checks for singular vs. plural
        return "${hourValue}s";
      } else if (picked.minute == 1) {
        return "${hourValue}s, $minValue";
      }
      return "${hourValue}s, ${minValue}s";
    }
  }
}
