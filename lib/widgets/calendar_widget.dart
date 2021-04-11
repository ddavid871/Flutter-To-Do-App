import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


// ignore: must_be_immutable
class CalendarWidget extends StatelessWidget {

  List<Meeting> meetings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Calendar',
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: Container(
          child: SfCalendar(
            view: CalendarView.week,
            showDatePickerButton: true,
            allowViewNavigation: true,
            allowedViews: <CalendarView>
            [
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
            firstDayOfWeek: 1,
            cellBorderColor: Colors.black38,

            specialRegions: _getTimeRegions(),
            dataSource: MeetingDataSource(_getDataSource()),
          ),
        ),
      ),
    );
  }

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    regions.add(TimeRegion(
        startTime: DateTime(2021, 4, 5, 0),
        endTime: DateTime(2021, 4, 5, 8),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1;BYDAY=SAT,SUN',
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
        color: Color(0xffbD3D3D3),
        text: 'Reserved'
    ));

    /*
    regions.add(TimeRegion(
        startTime: DateTime(2021, 4, 5, 10),
        endTime: DateTime(2021, 4, 5, 16),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1;BYDAY=SAT,SUN',
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
        color: Colors.blue,
        text: 'Work'
    ));

    regions.add(TimeRegion(
        startTime: DateTime(2021, 4, 5, 8),
        endTime: DateTime(2021, 4, 5, 10),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1;BYDAY=SAT,SUN',
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
        color: Colors.green,
        text: 'Capstone'
    ));
    */

    return regions;
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.month,
      dataSource: MeetingDataSource(_getDataSource()),
      // by default the month appointment display mode set as Indicator, we can
      // change the display mode as appointment using the appointment display
      // mode property
      monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    ));
  }
  */

  /*
  MeetingDataSource _getCalendarDataSource() {
    List<Meeting> meetings = <Meeting>[];
    meetings.add(Meeting(
        eventName: 'Capstone',
        from: DateTime(2021, 4, 5, 8),
        to: DateTime(2021, 4, 5, 10),
        background: Colors.green,
        isAllDay: false,
        recurrenceRule: 'FREQ=DAILY;BYDAY=SA,SU;INTERVAL=1;COUNT=8')
    );
    meetings.add(Meeting(
        eventName: 'Work',
        from: DateTime(2021, 4, 5, 10),
        to: DateTime(2021, 4, 5, 16),
        background: Colors.blue,
        isAllDay: false,
        recurrenceRule: 'FREQ=DAILY;BYDAY=SA,SU;INTERVAL=1;')
    );
    return MeetingDataSource(meetings);
  }
  */

  // https://www.textmagic.com/free-tools/rrule-generator
  List<Meeting> _getDataSource() {
    meetings = <Meeting>[];

    final DateTime today = DateTime.now();

    /*
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
    );
    */

    meetings.add(Meeting(
        eventName: 'Capstone',
        from: DateTime(today.year, today.month, 5, 8),
        to: DateTime(today.year, today.month, 5, 10),
        background: Colors.green,
        isAllDay: false,
        recurrenceRule: 'FREQ=DAILY;BYDAY=SA,SU;INTERVAL=1;UNTIL=20210414T060000Z')
    );

    meetings.add(Meeting(
        eventName: 'Work',
        from: DateTime(today.year, today.month, 5, 10),
        to: DateTime(today.year, today.month, 5, 16),
        background: Colors.blue,
        isAllDay: false,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=TU,TH;INTERVAL=1;UNTIL=20210414T060000Z')
    );

    return meetings;
  }

}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
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
  Meeting({this.eventName,
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
