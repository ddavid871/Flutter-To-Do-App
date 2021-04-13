
class Task {
  int _id;
  String _task;
  String _date;
  String _time;
  String _estTime;
  int _estTimeHour;
  int _estTimeMinute;
  String _taskRegion;
  String _taskRegionColor;
  String _status;

  Task(this._task, this._date, this._time, this._estTime, this._estTimeHour, this._estTimeMinute, this._taskRegion, this._taskRegionColor, this._status);
  Task.withId(this._id, this._task, this._date, this._time, this._estTime, this._estTimeHour, this._estTimeMinute, this._taskRegion, this._taskRegionColor, this._status);

  int get id => _id;
  String get task => _task;
  String get date => _date;
  String get time => _time;
  String get estTime => _estTime;
  int get estTimeHour => _estTimeHour;
  int get estTimeMinute => _estTimeMinute;
  String get taskRegion => _taskRegion;
  String get taskRegionColor => _taskRegionColor;
  String get status => _status;

  set task(String newTask) {
    if (newTask.length <= 255) {
      this._task = newTask;
    }
  }
  set date(String newDate) => this._date = newDate;
  set time(String newTime) => this._time = newTime;
  set estTime(String newEstTime) => this._estTime = newEstTime;
  set estTimeHour(int newEstTimeHour) => this._estTimeHour = newEstTimeHour;
  set estTimeMinute(int newEstTimeMinute) => this._estTimeMinute = newEstTimeMinute;
  set taskRegion(String newTaskRegion) => this._taskRegion = newTaskRegion;
  set taskRegionColor(String newTaskRegionColor) => this._taskRegionColor = newTaskRegionColor;
  set status(String newStatus) => this._status = newStatus;

  // Convert Task object into Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['task'] = _task;
    map['date'] = _date;
    map['time'] = _time;
    map['estTime'] = _estTime;
    map['estTimeHour'] = _estTimeHour;
    map['estTimeMinute'] = _estTimeMinute;
    map['taskRegion'] = _taskRegion;
    map['taskRegionColor'] = _taskRegionColor;
    map['status'] = _status;
    return map;
  }

  // Extract Task object from Map object
  Task.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._task = map['task'];
    this._date = map['date'];
    this._time = map['time'];
    this._estTime = map['estTime'];
    this._estTimeHour = map['estTimeHour'];
    this._estTimeMinute = map['estTimeMinute'];
    this._taskRegion = map['taskRegion'];
    this._taskRegionColor = map['taskRegionColor'];
    this._status = map['status'];
  }
}