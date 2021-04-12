// Modified from the Flutter TimePicker widget
// Original can be found here: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/time_picker.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_tasks/utilities/time_input.dart';

const Duration _kDialogSizeAnimationDuration = Duration(milliseconds: 200);
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

enum _TimePickerMode { hour, minute } // TODO: update to include days?

const double _kTimePickerHeaderControlHeight = 80.0;

const double _kTimePickerWidthPortrait = 328.0;

const double _kTimePickerHeightInput = 226.0;

const BorderRadius _kDefaultBorderRadius = BorderRadius.all(Radius.circular(4.0));
const ShapeBorder _kDefaultShape = RoundedRectangleBorder(borderRadius: _kDefaultBorderRadius);

// A passive fragment showing a string value.
class _StringFragment extends StatelessWidget {
  const _StringFragment({
    @required this.timeInputFormat,
  });

  final TimeInputFormat timeInputFormat;

  String _stringFragmentValue(TimeInputFormat timeInputFormat) {
    switch (timeInputFormat) {
      case TimeInputFormat.H_colon_mm:
      case TimeInputFormat.HH_colon_mm:
        return ':';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final TextStyle hourMinuteStyle = timePickerTheme.hourMinuteTextStyle ?? theme.textTheme.headline2;
    final Color textColor = timePickerTheme.hourMinuteTextColor ?? theme.colorScheme.onSurface;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Center(
          child: Text(
            _stringFragmentValue(timeInputFormat),
            style: hourMinuteStyle.apply(color: MaterialStateProperty.resolveAs(textColor, <MaterialState>{})),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}

class _TimePickerInput extends StatefulWidget {
  const _TimePickerInput({
    Key key,
    @required this.initialSelectedTime,
    @required this.helpText,
    @required this.onChanged,
  }) : assert(initialSelectedTime != null),
        assert(onChanged != null),
        super(key: key);

  /// The time initially selected when the dialog is shown.
  final TimeInput initialSelectedTime;

  /// Optionally provide your own help text to the time picker.
  final String helpText;

  final ValueChanged<TimeInput> onChanged;

  @override
  _TimePickerInputState createState() => _TimePickerInputState();
}

class _TimePickerInputState extends State<_TimePickerInput> {
  TimeInput _selectedTime;
  bool hourHasError = false;
  bool minuteHasError = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialSelectedTime;
  }

  int _parseHour(String value) {
    if (value == null) {
      return null;
    }

    int newHour = int.tryParse(value);
    if (newHour == null) {
      return null;
    }

    return newHour;
  }

  int _parseMinute(String value) {
    if (value == null) {
      return null;
    }

    final int newMinute = int.tryParse(value);
    if (newMinute == null) {
      return null;
    }

    return newMinute;
  }

  void _handleHourSavedSubmitted(String value) {
    final int newHour = _parseHour(value);
    if (newHour != null) {
      _selectedTime = TimeInput(hour: newHour, minute: _selectedTime.minute);
      widget.onChanged(_selectedTime);
    }
  }

  void _handleHourChanged(String value) {
    final int newHour = _parseHour(value);
    if (newHour != null && value.length == 2) {
      // If a valid hour is typed, move focus to the minute TextField.
      FocusScope.of(context).nextFocus();
    }
  }

  void _handleMinuteSavedSubmitted(String value) {
    final int newMinute = _parseMinute(value);
    if (newMinute != null) {
      _selectedTime = TimeInput(hour: _selectedTime.hour, minute: int.parse(value));
      widget.onChanged(_selectedTime);
    }
  }

  String _validateHour(String value) {
    final int newHour = _parseHour(value);
    setState(() {
      hourHasError = newHour == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newHour == null ? '' : null;
  }

  String _validateMinute(String value) {
    final int newMinute = _parseMinute(value);
    setState(() {
      minuteHasError = newMinute == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newMinute == null ? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    final TimeInputFormat timeInputFormat = TimeInputFormat.HH_colon_mm;
    final TextStyle hourMinuteStyle = TimePickerTheme.of(context).hourMinuteTextStyle ?? theme.textTheme.headline2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.helpText ?? MaterialLocalizations.of(context).timePickerInputHelpText,
            style: TimePickerTheme.of(context).helpTextStyle ?? theme.textTheme.overline,
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 8.0),
                          _HourTextField(
                            selectedTime: _selectedTime,
                            style: hourMinuteStyle,
                            validator: _validateHour,
                            onSavedSubmitted: _handleHourSavedSubmitted,
                            onChanged: _handleHourChanged,
                          ),
                          const SizedBox(height: 8.0),
                          if (!hourHasError && !minuteHasError)
                            ExcludeSemantics(
                              child: Text(
                                MaterialLocalizations.of(context).timePickerHourLabel,
                                style: theme.textTheme.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      height: _kTimePickerHeaderControlHeight,
                      child: _StringFragment(timeInputFormat: timeInputFormat),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 8.0),
                          _MinuteTextField(
                            selectedTime: _selectedTime,
                            style: hourMinuteStyle,
                            validator: _validateMinute,
                            onSavedSubmitted: _handleMinuteSavedSubmitted,
                          ),
                          const SizedBox(height: 8.0),
                          if (!hourHasError && !minuteHasError)
                            ExcludeSemantics(
                              child: Text(
                                MaterialLocalizations.of(context).timePickerMinuteLabel,
                                style: theme.textTheme.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hourHasError || minuteHasError)
            Text(
              MaterialLocalizations.of(context).invalidTimeLabel,
              style: theme.textTheme.bodyText2.copyWith(color: theme.colorScheme.error),
            )
          else
            const SizedBox(height: 2.0),
        ],
      ),
    );
  }
}

class _HourTextField extends StatelessWidget {
  const _HourTextField({
    Key key,
    @required this.selectedTime,
    @required this.style,
    @required this.validator,
    @required this.onSavedSubmitted,
    @required this.onChanged,
  }) : super(key: key);

  final TimeInput selectedTime;
  final TextStyle style;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSavedSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      selectedTime: selectedTime,
      isHour: true,
      style: style,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
      onChanged: onChanged,
    );
  }
}

class _MinuteTextField extends StatelessWidget {
  const _MinuteTextField({
    Key key,
    @required this.selectedTime,
    @required this.style,
    @required this.validator,
    @required this.onSavedSubmitted,
  }) : super(key: key);

  final TimeInput selectedTime;
  final TextStyle style;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSavedSubmitted;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      selectedTime: selectedTime,
      isHour: false,
      style: style,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
    );
  }
}

class _HourMinuteTextField extends StatefulWidget {
  const _HourMinuteTextField({
    Key key,
    @required this.selectedTime,
    @required this.isHour,
    @required this.style,
    @required this.validator,
    @required this.onSavedSubmitted,
    this.onChanged,
  }) : super(key: key);

  final TimeInput selectedTime;
  final bool isHour;
  final TextStyle style;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSavedSubmitted;
  final ValueChanged<String> onChanged;

  @override
  _HourMinuteTextFieldState createState() => _HourMinuteTextFieldState();
}

class _HourMinuteTextFieldState extends State<_HourMinuteTextField> {
  TextEditingController controller;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()..addListener(() {
      setState(() { }); // Rebuild.
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller ??= TextEditingController(text: _formattedValue);
  }

  String get _formattedValue {
    if (!widget.isHour) {
      final int minute = widget.selectedTime.minute;
      return minute < 10 ? '0$minute' : minute.toString();
    } else {
      final int hour = widget.selectedTime.hour;
      return hour < 10 ? '0$hour' : hour.toString(); // fixme - 0-99 values only
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final InputDecorationTheme inputDecorationTheme = timePickerTheme.inputDecorationTheme;
    InputDecoration inputDecoration;
    if (inputDecorationTheme != null) {
      inputDecoration = const InputDecoration().applyDefaults(inputDecorationTheme);
    } else {
      inputDecoration = InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        hintStyle: widget.style.copyWith(color: colorScheme.onSurface.withOpacity(0.36)),
        // TODO(rami-a): Remove this logic once https://github.com/flutter/flutter/issues/54104 is fixed.
        errorStyle: const TextStyle(fontSize: 0.0, height: 0.0), // Prevent the error text from appearing.
      );
    }
    final Color unfocusedFillColor = timePickerTheme.hourMinuteColor ?? colorScheme.onSurface.withOpacity(0.12);
    inputDecoration = inputDecoration.copyWith(
      // Remove the hint text when focused because the centered cursor appears
      // odd above the hint text.
      hintText: focusNode.hasFocus ? null : _formattedValue,
      fillColor: focusNode.hasFocus ? Colors.transparent : inputDecorationTheme?.fillColor ?? unfocusedFillColor,
    );

    return SizedBox(
      height: _kTimePickerHeaderControlHeight,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: TextFormField(
          expands: true,
          maxLines: null,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(2),
          ],
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: widget.style.copyWith(color: timePickerTheme.hourMinuteTextColor ?? colorScheme.onSurface),
          controller: controller,
          decoration: inputDecoration,
          validator: widget.validator,
          onEditingComplete: () => widget.onSavedSubmitted(controller.text),
          onSaved: widget.onSavedSubmitted,
          onFieldSubmitted: widget.onSavedSubmitted,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// A material design time picker designed to appear inside a popup dialog.
//  The selected time is reported by calling [Navigator.pop].
class _TimePickerDialog extends StatefulWidget {
  // Creates a material time picker.
  const _TimePickerDialog({
    Key key,
    @required this.initialTime,
    @required this.cancelText,
    @required this.confirmText,
    @required this.helpText,
  }) : //assert(initialTime != null), // fixme?
        super(key: key);

  // The time initially selected when the dialog is shown.
  final TimeInput initialTime;

  // Optionally provide your own text for the cancel button.
  // If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String cancelText;

  // Optionally provide your own text for the confirm button.
  // If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String confirmText;

  // Optionally provide your own help text to the header of the time picker.
  final String helpText;

  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _autoValidate = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    _announceModeOnce();
  }

  _TimePickerMode _mode = _TimePickerMode.hour;
  _TimePickerMode _lastModeAnnounced;
  bool _autoValidate;

  TimeInput get selectedTime => _selectedTime;
  TimeInput _selectedTime;

  Timer _vibrateTimer;
  MaterialLocalizations localizations;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _vibrateTimer?.cancel();
        _vibrateTimer = Timer(_kVibrateCommitDelay, () {
          HapticFeedback.vibrate();
          _vibrateTimer = null;
        });
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _announceModeOnce() {
    if (_lastModeAnnounced == _mode) {
      // Already announced it.
      return;
    }

    switch (_mode) {
      case _TimePickerMode.hour:
        _announceToAccessibility(context, localizations.timePickerHourModeAnnouncement);
        break;
      case _TimePickerMode.minute:
        _announceToAccessibility(context, localizations.timePickerMinuteModeAnnouncement);
        break;
    }
    _lastModeAnnounced = _mode;
  }

  void _handleTimeChanged(TimeInput value) {
    _vibrate();
    setState(() {
      _selectedTime = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() { _autoValidate = true; });
      return;
    }
    form.save();

    Navigator.pop(context, _selectedTime);
  }

  Size _dialogSize(BuildContext context) {
    // Constrain the textScaleFactor to prevent layout issues. Since only some
    // parts of the time picker scale up with textScaleFactor, we cap the factor
    // to 1.1 as that provides enough space to reasonably fit all the content.
    final double textScaleFactor = math.min(MediaQuery.of(context).textScaleFactor, 1.1);

    double timePickerWidth;
    double timePickerHeight;

    timePickerWidth = _kTimePickerWidthPortrait;
    timePickerHeight = _kTimePickerHeightInput;

    return Size(timePickerWidth, timePickerHeight * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    final ShapeBorder shape = TimePickerTheme.of(context).shape ?? _kDefaultShape;

    final Widget actions = Row(
      children: <Widget>[
        const SizedBox(width: 10.0),
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.centerEnd,
            constraints: const BoxConstraints(minHeight: 52.0),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OverflowBar(
              spacing: 8,
              overflowAlignment: OverflowBarAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: _handleCancel,
                  child: Text(widget.cancelText ?? localizations.cancelButtonLabel),
                ),
                TextButton(
                  onPressed: _handleOk,
                  child: Text(widget.confirmText ?? localizations.okButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget picker;

    picker = Form(
      key: _formKey,
      // ignore: deprecated_member_use
      autovalidate: _autoValidate,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _TimePickerInput(
              initialSelectedTime: _selectedTime,
              helpText: widget.helpText,
              onChanged: _handleTimeChanged,
            ),
            actions,
          ],
        ),
      ),
    );

    final Size dialogSize = _dialogSize(context);
    return Dialog(
      shape: shape,
      backgroundColor: TimePickerTheme.of(context).backgroundColor ?? theme.colorScheme.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 0.0,
      ),
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _kDialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: picker,
      ),
    );
  }

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }
}

// Shows a dialog containing a material design time picker.
Future<TimeInput> showEstTimePicker({
  @required BuildContext context,
  TimeInput initialTime, // @required, fixme
  TransitionBuilder builder,
  bool useRootNavigator = true,
  String cancelText,
  String confirmText,
  String helpText,
  RouteSettings routeSettings,
}) async {
  assert(context != null);
  //assert(initialTime != null); // fixme?
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context));

  final Widget dialog = _TimePickerDialog(
    initialTime: initialTime,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
  );
  return await showDialog<TimeInput>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
    routeSettings: routeSettings,
  );
}

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}
