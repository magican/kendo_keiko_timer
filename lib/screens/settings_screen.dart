import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models.dart';

/// Names of colours in Colors.primaries
var colorNames = {
  Colors.red: 'Red',
  Colors.pink: 'Pink',
  Colors.purple: 'Purple',
  Colors.deepPurple: 'Deep purple',
  Colors.indigo: 'Indigo',
  Colors.blue: 'Blue',
  Colors.lightBlue: 'Light blue',
  Colors.cyan: 'Cyan',
  Colors.teal: 'Teal',
  Colors.green: 'Green',
  Colors.lightGreen: 'Light green',
  Colors.lime: 'Lime',
  Colors.yellow: 'Yellow',
  Colors.amber: 'Amber',
  Colors.orange: 'Orange',
  Colors.deepOrange: 'Deep orange',
  Colors.brown: 'Brown',
  Colors.blueGrey: 'Blue grey',
};

class SettingsScreen extends StatefulWidget {
  final Settings settings;

  final Function onSettingsChanged;

  SettingsScreen({required this.settings, required this.onSettingsChanged});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class AudioSelectListItem extends StatelessWidget {
  final String title;
  final String value;
  final Function(String?) onChanged;

  AudioSelectListItem(
      {required this.title, required this.onChanged, required this.value});

  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: Icon(Icons.play_circle_outline),
        onPressed: () {
          player.play(AssetSource(value));
        },
      ),
      title: Text(title, style: Theme.of(context).textTheme.subtitle2),
      subtitle: DropdownButton<String?>(
        isDense: true,
        value: value,
        items: [
          DropdownMenuItem(child: Text('Низкий тон'), value: 'pip.mp3'),
          DropdownMenuItem(child: Text('Высокий тон'), value: 'boop.mp3'),
          DropdownMenuItem(child: Text('Динь дон!'), value: 'dingdingding.mp3'),
          DropdownMenuItem(child: Text('Хаджимэ!'), value: 'hajime.mp3'),
          DropdownMenuItem(child: Text('Ямэ!'), value: 'yame.mp3'),
        ],
        isExpanded: true,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'Тема',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SwitchListTile(
            title: Text('Тёмная тема'),
            value: widget.settings.nightMode,
            onChanged: (nightMode) {
              widget.settings.nightMode = nightMode;
              widget.onSettingsChanged();
            },
          ),
          SwitchListTile(
            title: Text('Беззвучный режим'),
            value: widget.settings.silentMode,
            onChanged: (silentMode) {
              widget.settings.silentMode = silentMode;
              widget.onSettingsChanged();
            },
          ),
          ListTile(
            title: Text('Светлая тема'),
            subtitle: Text(colorNames[widget.settings.primarySwatch] ?? ''),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        availableColors: Colors.primaries,
                        pickerColor: widget.settings.primarySwatch,
                        onColorChanged: (Color color) {
                          widget.settings.primarySwatch =
                              color as MaterialColor;
                          widget.onSettingsChanged();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Divider(height: 10),
          ListTile(
            title: Text(
              'Звуки',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          AudioSelectListItem(
            value: widget.settings.countdownPip,
            title: 'Обратный отсчёт',
            onChanged: (String? value) {
              widget.settings.countdownPip = value!;
              widget.onSettingsChanged();
            },
          ),
          // AudioSelectListItem(
          //   value: widget.settings.startRep,
          //   title: 'Start next Repetition',
          //   onChanged: (String? value) {
          //     widget.settings.startRep = value!;
          //     widget.onSettingsChanged();
          //   },
          // ),
          // AudioSelectListItem(
          //   value: widget.settings.startRest,
          //   title: 'Rest',
          //   onChanged: (String? value) {
          //     widget.settings.startRest = value!;
          //     widget.onSettingsChanged();
          //   },
          // ),
          AudioSelectListItem(
            value: widget.settings.startKotai,
            title: 'Котай (переход)',
            onChanged: (String? value) {
              widget.settings.startKotai = value!;
              widget.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: widget.settings.startSet,
            title: 'Старт кейко',
            onChanged: (String? value) {
              widget.settings.startSet = value!;
              widget.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: widget.settings.endWorkout,
            title: 'Окончание тренировки (играет дважды)',
            onChanged: (String? value) {
              widget.settings.endWorkout = value!;
              widget.onSettingsChanged();
            },
          ),
        ],
      ),
    );
  }
}
