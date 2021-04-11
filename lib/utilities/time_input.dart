// Modified from the TimeOfDay class in time.dart
// Original found here: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/time.dart

import 'dart:ui' show hashValues;

import 'package:flutter/widgets.dart';

// A value representing a time
@immutable
class TimeInput {
  // Creates a time with an hour and minute.
  const TimeInput({ @required this.hour, @required this.minute });

  // The number of hours in one work day, i.e. 8.
  static const int hoursPerWorkDay = 8; // TODO - make useful

  // The number of minutes in one hour, i.e. 60.
  static const int minutesPerHour = 60;

  // Returns a new TimeOfDay with the hour and/or minute replaced.
  TimeInput replacing({ int hour, int minute }) {
    assert(hour == null || hour >= 0);
    assert(minute == null || minute >= 0);
    return TimeInput(hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  // The selected hour
  final int hour;

  // The selected minute.
  final int minute;

  @override
  bool operator ==(Object other) {
    return other is TimeInput
        && other.hour == hour
        && other.minute == minute;
  }

  @override
  int get hashCode => hashValues(hour, minute);

  @override
  String toString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10)
        return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);

    return '$TimeInput($hourLabel:$minuteLabel)';
  }
}

// Determines how the time picker invoked using [showTimePicker] formats and
// lays out the time controls.
enum TimeInputFormat {
  /// Corresponds to the ICU 'HH:mm' pattern.
  ///
  /// This format uses 24-hour two-digit zero-padded hours. Controls are always
  /// laid out horizontally. Hours are separated from minutes by one colon
  /// character.
  HH_colon_mm,

  /// Corresponds to the ICU 'H:mm' pattern.
  ///
  /// This format uses 24-hour non-padded variable-length hours. Controls are
  /// always laid out horizontally. Hours are separated from minutes by one
  /// colon character.
  H_colon_mm,
}

/// Describes how hours are formatted.
enum HourFormat {
  /// Zero-padded two-digit 24-hour format ranging from "00" to "23".
  HH,

  /// Non-padded variable-length 24-hour format ranging from "0" to "23".
  H,

  /// Non-padded variable-length hour in day period format ranging from "1" to
  /// "12".
  h,
}

/// The [HourFormat] used for the given [TimeInputFormat].
HourFormat hourFormat({ @required TimeInputFormat of }) {
  switch (of) {
    case TimeInputFormat.H_colon_mm:
      return HourFormat.H;
    case TimeInputFormat.HH_colon_mm:
  }

  return null;
}
