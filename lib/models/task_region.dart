
class TaskRegion {
  int _id;
  String _taskRegion;
  String _regionStartDate;
  String _regionStartTime;
  String _regionEndTime;
  String _regionRRuleOption;
  String _regionRRule;
  String _regionColor;

  /* EXAMPLE
  TimeRegion(
        startTime: DateTime(2021, 4, 5, 0),
        endTime: DateTime(2021, 4, 5, 8),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1;BYDAY=SAT,SUN',
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
        color: Color(0xffbD3D3D3),
        text: 'Reserved'));
 */

  TaskRegion(this._taskRegion, this._regionStartDate, this._regionStartTime, this._regionEndTime, this._regionRRuleOption, this._regionRRule, this._regionColor);
  TaskRegion.withId(this._id, this._taskRegion, this._regionStartDate, this._regionStartTime, this._regionEndTime, this._regionRRuleOption, this._regionRRule, this._regionColor);

  int get id => _id;
  String get taskRegion => _taskRegion;
  String get regionStartDate => _regionStartDate;
  String get regionStartTime => _regionStartTime;
  String get regionEndTime => _regionEndTime;
  String get regionRRuleOption => _regionRRuleOption;
  String get regionRRule => _regionRRule;
  String get regionColor => _regionColor;

  set taskRegion(String newTaskRegion) {
    if (newTaskRegion.length <= 255) {
      this._taskRegion = newTaskRegion;
    }
  }
  set regionStartDate(String newRegionStartDate) => this._regionStartDate = newRegionStartDate;
  set regionStartTime(String newRegionStartTime) => this._regionStartTime = newRegionStartTime;
  set regionEndTime(String newRegionEndTime) => this._regionEndTime = newRegionEndTime;
  set regionRRuleOption(String newRegionRRuleOption) => this._regionRRuleOption = newRegionRRuleOption;
  set regionRRule(String newRegionRRule) => this._regionRRule = newRegionRRule;
  set regionColor(String newRegionColor) => this._regionColor = newRegionColor;

  // Convert Task Region object into Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) map['id'] = _id;
    map['taskRegion'] = _taskRegion;
    map['regionStartDate'] = _regionStartDate;
    map['regionStartTime'] = _regionStartTime;
    map['regionEndTime'] = _regionEndTime;
    map['regionRRuleOption'] = _regionRRuleOption;
    map['regionRRule'] = _regionRRule;
    map['regionColor'] = _regionColor;
    return map;
  }

  // Extract Task Region object from Map object
  TaskRegion.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._taskRegion = map['taskRegion'];
    this._regionStartDate = map['regionStartDate'];
    this._regionStartTime = map['regionStartTime'];
    this._regionEndTime = map['regionEndTime'];
    this._regionRRuleOption = map['regionRRuleOption'];
    this._regionRRule = map['regionRRule'];
    this._regionColor = map['regionColor'];
  }
}