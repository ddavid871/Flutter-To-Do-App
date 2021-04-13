
class CalendarSettings {
  int _id;
  int _defaultView;
  int _weekFirstDay;

  CalendarSettings(this._defaultView, this._weekFirstDay);
  CalendarSettings.withId(this._id, this._defaultView, this._weekFirstDay);

  int get id => _id;
  int get defaultView => _defaultView;
  int get weekFirstDay => _weekFirstDay;

  set defaultView(int newDefaultView) => this._defaultView;
  set weekFirstDay(int newWeekFirstDay) => this._weekFirstDay;

  // Convert Calendar Settings object into Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['defaultView'] = _defaultView;
    map['weekFirstDay'] = _weekFirstDay;
    return map;
  }

  // Extract Calendar Settings object from Map object
  CalendarSettings.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._defaultView = map['defaultView'];
    this._weekFirstDay = map['weekFirstDay'];
  }
}