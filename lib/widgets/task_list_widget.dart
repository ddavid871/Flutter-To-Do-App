import 'package:flutter/material.dart';

class TaskListWidget extends StatelessWidget {
  TaskListWidget({
    Key key,
    this.title,
    this.sub1,
    this.sub2,
    this.delete,
    this.color,
    this.trailing,
    this.status,
  }) : super(key: key);

  final String title;
  final String sub1;
  final String sub2;
  final Widget delete;
  final Widget color;
  final Widget trailing;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  '$sub1 · $sub2',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 15),
                ),
                Row(children: <Widget>[
                   color,
                    Text(
                      '$status',
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).primaryColor,
                         fontSize: 15),
                  )]),
              ],
            ),
          ),
          delete,
          trailing,
        ]));
  }
}
