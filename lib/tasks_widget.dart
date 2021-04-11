import 'package:flutter/material.dart';
import 'models/task.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}


// CONT: https://github.com/MobMaxime/Flutter-To-Do-App


class _TodoListState extends State<TaskWidget> {
  List<Task> _todoItems = [];

  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    // fixme - different divisions
    return Container(
        padding: EdgeInsets.only(left: 16),
        child: Scaffold(
          body: ListView.builder(itemBuilder: (ctx, index) {
            if (index == _todoItems.length) return null;
            return ListTile(
              title: Text(_todoItems[index].task),
              subtitle: Text(_todoItems[index].id.toString()),
              trailing: IconButton(
                icon: Icon((_isSelected) ? Icons.check_box : Icons
                    .check_box_outline_blank),
                onPressed: () { // fixme - change text color and strikethru?
                  setState(() {
                    _isSelected = !_isSelected;
                  });
                },
              ),
            );
          }),
          floatingActionButton: new FloatingActionButton(
              onPressed: _pushAddTaskScreen,
              tooltip: 'Add Task',
              child: new Icon(Icons.add)),
        ),
    );
  }

  void _addTaskItem(String taskTitle) {
    setState(() {
      int index = _todoItems.length;
      _todoItems.add(Task.withId(index, taskTitle, '', '', '', 1, 0, ''));
    });
  }

  void _pushAddTaskScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) {
          return new Scaffold(
              appBar: new AppBar(
                  title: new Text('Add a new task'),
              ),
              body: new TextField(
                autofocus: true,
                onSubmitted: (val) {
                  _addTaskItem(val);
                  Navigator.pop(context); // Close the add task screen
                },
                decoration: new InputDecoration(
                    hintText: 'Task title',
                    contentPadding: const EdgeInsets.all(16.0)),
              ));
        }));
  }
}
