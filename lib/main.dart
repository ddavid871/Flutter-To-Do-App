import 'package:flutter/material.dart';
import 'package:flutter_tasks/screens/calendar_settings.dart';
import 'package:flutter_tasks/widgets/region_widget.dart';
import 'package:flutter_tasks/widgets/todo_widget.dart';

import 'package:flutter_tasks/widgets/calendar_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Tasks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  // Navigation
  int _currentIndex = 0;
  final List<Widget> _children = [
    TodoWidget(),
    RegionWidget(),
    CalendarWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(Icons.list),
              label: 'Tasks',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_mosaic),
              label: 'Task Regions',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Calendar',
            ),
          ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}