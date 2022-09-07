import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../utils.dart';
import '../widgets/durationpicker.dart';
import 'settings_screen.dart';
import 'workout_screen.dart';

class KendoKeikoScreen extends StatefulWidget {
  final Settings settings;
  final SharedPreferences prefs;
  final Function onSettingsChanged;

  KendoKeikoScreen({
    required this.settings,
    required this.prefs,
    required this.onSettingsChanged,
  });

  @override
  State<StatefulWidget> createState() => _KendoKeikoScreenState();
}

class _KendoKeikoScreenState extends State<KendoKeikoScreen> {
  KendoKeiko _kendo_keiko = defaultKendoKeiko;

  @override
  initState() {
    var json = widget.prefs.getString('kendo_keiko');
    if (json != null) {
      _kendo_keiko = KendoKeiko.fromJson(jsonDecode(json));
    }
    super.initState();
  }

  _onKendoKeikoChanged() {
    setState(() {});
    _saveKendoKeiko();
  }

  _saveKendoKeiko() {
    widget.prefs.setString('kendo_keiko', jsonEncode(_kendo_keiko.toJson()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kendo Keiko Timer'),
        leading: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 44,
            minHeight: 44,
            maxWidth: 64,
            maxHeight: 64,
          ),
          child: Image.asset("assets/icons/kendo_keiko_timer.png",
              fit: BoxFit.cover),
        ),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(widget.settings.silentMode
                  ? Icons.volume_off
                  : Icons.volume_up),
              onPressed: () {
                widget.settings.silentMode = !widget.settings.silentMode;
                widget.onSettingsChanged();
                var snackBar = SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text(
                        'Silent mode ${!widget.settings.silentMode ? 'de' : ''}activated'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              tooltip: 'Включить беззвучный режим',
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                      settings: widget.settings,
                      onSettingsChanged: widget.onSettingsChanged),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Кол-во кейко за тренировку'),
            subtitle: Text('${_kendo_keiko.sets}'),
            leading: Icon(Icons.checklist, color: Colors.amber),
            onTap: () {
              int _value = _kendo_keiko.sets;
              showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      title: Text('Общее кол-во кейко'),
                      content: NumberPicker(
                        value: _value,
                        minValue: 1,
                        maxValue: 30,
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('ОТМЕНА'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(_value),
                          child: Text('OK'),
                        )
                      ],
                    );
                  });
                },
              ).then((sets) {
                if (sets == null) return;
                _kendo_keiko.sets = sets;
                _onKendoKeikoChanged();
              });
            },
          ),
          // ListTile(
          //   title: Text('Reps'),
          //   subtitle: Text('${_kendo_keiko.reps}'),
          //   leading: Icon(Icons.repeat),
          //   onTap: () {
          //     int _value = _kendo_keiko.reps;
          //     showDialog<int>(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return StatefulBuilder(builder: (context, setState) {
          //           return AlertDialog(
          //             title: Text('Repetitions in each Keiko set'),
          //             content: NumberPicker(
          //               value: _value,
          //               minValue: 1,
          //               maxValue: 10,
          //               onChanged: (value) {
          //                 setState(() {
          //                   _value = value;
          //                 });
          //               },
          //             ),
          //             actions: [
          //               TextButton(
          //                 onPressed: () => Navigator.of(context).pop(),
          //                 child: Text('ОТМЕНА'),
          //               ),
          //               TextButton(
          //                 onPressed: () => Navigator.of(context).pop(_value),
          //                 child: Text('OK'),
          //               )
          //             ],
          //           );
          //         });
          //       },
          //     ).then((reps) {
          //       if (reps == null) return;
          //       _kendo_keiko.reps = reps;
          //       _onKendoKeikoChanged();
          //     });
          //   },
          // ),
          Divider(
            height: 10,
          ),
          ListTile(
            title: Text('Обратный отсчёт ...'),
            subtitle: Text(formatTime(_kendo_keiko.startDelay)),
            leading: Icon(Icons.timer, color: Colors.blue),
            onTap: () {
              showDialog<Duration>(
                context: context,
                builder: (BuildContext context) {
                  return DurationPickerDialog(
                    initialDuration: _kendo_keiko.startDelay,
                    title: Text('Время до начала кейко'),
                  );
                },
              ).then((startDelay) {
                if (startDelay == null) return;
                _kendo_keiko.startDelay = startDelay;
                _onKendoKeikoChanged();
              });
            },
          ),
          ListTile(
            title: Text('Кейко'),
            subtitle: Text(formatTime(_kendo_keiko.keikoTime)),
            leading: Icon(Icons.directions_run, color: Colors.green),
            onTap: () {
              showDialog<Duration>(
                context: context,
                builder: (BuildContext context) {
                  return DurationPickerDialog(
                    initialDuration: _kendo_keiko.keikoTime,
                    title: Text('Время на 1 кейко'),
                  );
                },
              ).then((keikoTime) {
                if (keikoTime == null) return;
                _kendo_keiko.keikoTime = keikoTime;
                _onKendoKeikoChanged();
              });
            },
          ),
          // ListTile(
          //   title: Text('Rest Time'),
          //   subtitle: Text(formatTime(_kendo_keiko.restTime)),
          //   leading: Icon(Icons.timer),
          //   onTap: () {
          //     showDialog<Duration>(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return DurationPickerDialog(
          //           initialDuration: _kendo_keiko.restTime,
          //           title: Text('Rest time between repetitions'),
          //         );
          //       },
          //     ).then((restTime) {
          //       if (restTime == null) return;
          //       _kendo_keiko.restTime = restTime;
          //       _onKendoKeikoChanged();
          //     });
          //   },
          // ),
          ListTile(
            title: Text('Котай'),
            subtitle: Text(formatTime(_kendo_keiko.kotaiTime)),
            leading: Icon(Icons.rotate_90_degrees_ccw, color: Colors.red),
            onTap: () {
              showDialog<Duration>(
                context: context,
                builder: (BuildContext context) {
                  return DurationPickerDialog(
                    initialDuration: _kendo_keiko.kotaiTime,
                    title: Text('Время на котай'),
                  );
                },
              ).then((kotaiTime) {
                if (kotaiTime == null) return;
                _kendo_keiko.kotaiTime = kotaiTime;
                _onKendoKeikoChanged();
              });
            },
          ),
          Divider(height: 10),
          ListTile(
            title: Text(
              'Общее время кейко',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(formatTime(_kendo_keiko.getTotalTime())),
            leading: Icon(Icons.timelapse, color: Colors.grey),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkoutScreen(
                      settings: widget.settings, kendo_keiko: _kendo_keiko)));
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).primaryTextTheme.button?.color,
        tooltip: 'Да начнётся Кейко!',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
