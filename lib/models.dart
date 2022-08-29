import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var player = AudioPlayer();

KendoKeiko get defaultKendoKeiko => KendoKeiko(
      sets: 10,
      reps: 1,
      startDelay: Duration(seconds: 13),
      keikoTime: Duration(seconds: 150),
      restTime: Duration(seconds: 10),
      kotaiTime: Duration(seconds: 13),
    );

class Settings {
  final SharedPreferences _prefs;

  late bool nightMode;
  late bool silentMode;
  late MaterialColor primarySwatch;
  late String countdownPip;
  late String startRep;
  late String startRest;
  late String startKotai;
  late String startSet;
  late String endWorkout;
  late String hajime;
  late String yame;

  Settings(this._prefs) {
    Map<String, dynamic> json =
        jsonDecode(_prefs.getString('settings') ?? '{}');
    nightMode = json['nightMode'] ?? false;
    silentMode = json['silentMode'] ?? false;
    primarySwatch = Colors.primaries[
        json['primarySwatch'] ?? Colors.primaries.indexOf(Colors.deepPurple)];
    countdownPip = json['countdownPip'] ?? 'pip.mp3';
    startRep = json['startRep'] ?? 'boop.mp3';
    startRest = json['startRest'] ?? 'dingdingding.mp3';
    startKotai = json['startKotai'] ?? 'dingdingding.mp3';
    startSet = json['startSet'] ?? 'boop.mp3';
    endWorkout = json['endWorkout'] ?? 'dingdingding.mp3';
    hajime = json['hajime'] ?? 'hajime.mp3';
    yame = json['yame'] ?? 'yame.mp3';
  }

  save() {
    _prefs.setString('settings', jsonEncode(this));
  }

  Map<String, dynamic> toJson() => {
        'nightMode': nightMode,
        'silentMode': silentMode,
        'primarySwatch': Colors.primaries.indexOf(primarySwatch),
        'countdownPip': countdownPip,
        'startRep': startRep,
        'startRest': startRest,
        'startKotai': startKotai,
        'startSet': startSet,
        'endWorkout': endWorkout,
        'hajime': hajime,
        'yame': yame,
      };
}

class KendoKeiko {
  /// Sets in a workout
  int sets;

  /// Reps in a set
  int reps;

  /// Time to practice for in each rep
  Duration keikoTime;

  /// Rest time between reps
  Duration restTime;

  /// Kotai (Break) time between sets
  Duration kotaiTime;

  /// Initial countdown before starting workout
  Duration startDelay;

  KendoKeiko({
    required this.sets,
    required this.reps,
    required this.startDelay,
    required this.keikoTime,
    required this.restTime,
    required this.kotaiTime,
  });

  Duration getTotalTime() {
    return (keikoTime * sets * reps) +
        (restTime * sets * (reps - 1)) +
        (kotaiTime * (sets - 1));
  }

  KendoKeiko.fromJson(Map<String, dynamic> json)
      : sets = json['sets'],
        reps = json['reps'],
        keikoTime = Duration(seconds: json['keikoTime']),
        restTime = Duration(seconds: json['restTime']),
        kotaiTime = Duration(seconds: json['kotaiTime']),
        startDelay = Duration(seconds: json['startDelay']);

  Map<String, dynamic> toJson() => {
        'sets': sets,
        'reps': reps,
        'keikoTime': keikoTime.inSeconds,
        'restTime': restTime.inSeconds,
        'kotaiTime': kotaiTime.inSeconds,
        'startDelay': startDelay.inSeconds,
      };
}

enum WorkoutState { initial, starting, practicing, resting, kotai, finished }

class Workout {
  Settings _settings;

  KendoKeiko _config;

  /// Callback for when the workout's state has changed.
  Function _onStateChange;

  WorkoutState _step = WorkoutState.initial;

  Timer? _timer;

  /// Time left in the current step
  late Duration _timeLeft;

  Duration _totalTime = Duration(seconds: 0);

  /// Current set
  int _set = 0;

  /// Current rep
  int _rep = 0;

  Workout(this._settings, this._config, this._onStateChange);

  /// Starts or resumes the workout
  start() {
    if (_step == WorkoutState.initial) {
      _step = WorkoutState.starting;
      if (_config.startDelay.inSeconds == 0) {
        _nextStep();
      } else {
        _timeLeft = _config.startDelay;
      }
    }
    _timer = Timer.periodic(Duration(seconds: 1), _tick);
    _onStateChange();
  }

  /// Pauses the workout
  pause() {
    _timer?.cancel();
    _onStateChange();
  }

  /// Stops the timer without triggering the state change callback.
  dispose() {
    _timer?.cancel();
  }

  _tick(Timer timer) {
    if (_step != WorkoutState.starting) {
      _totalTime += Duration(seconds: 1);
    }

    if (_timeLeft.inSeconds == 1) {
      _nextStep();
    } else {
      _timeLeft -= Duration(seconds: 1);
      if (_timeLeft.inSeconds <= 3 && _timeLeft.inSeconds >= 1) {
        _playSound(_settings.countdownPip);
      }
    }

    _onStateChange();
  }

  /// Moves the workout to the next step and sets up state for it.
  _nextStep() {
    if (_step == WorkoutState.practicing) {
      if (rep == _config.reps) {
        if (set == _config.sets) {
          _finish();
        } else {
          _startKotai();
        }
      } else {
        _startRest();
      }
    } else if (_step == WorkoutState.resting) {
      _startRep();
    } else if (_step == WorkoutState.starting || _step == WorkoutState.kotai) {
      _startSet();
    }
  }

  Future _playSound(String sound) {
    if (_settings.silentMode) {
      return Future.value();
    }
    return player.play(AssetSource(sound));
  }

  _startRest() {
    _step = WorkoutState.resting;
    if (_config.restTime.inSeconds == 0) {
      _nextStep();
      return;
    }
    _timeLeft = _config.restTime;
    _playSound(_settings.startRest);
  }

  _startRep() {
    _rep++;
    _step = WorkoutState.practicing;
    _timeLeft = _config.keikoTime;
    _playSound(_settings.startRep);
  }

  _startKotai() {
    _step = WorkoutState.kotai;
    if (_config.kotaiTime.inSeconds == 0) {
      _nextStep();
      return;
    }
    _timeLeft = _config.kotaiTime;
    _playSound(_settings.startKotai);
    // _playSound(_settings.yame);
  }

  _startSet() {
    _set++;
    _rep = 1;
    _step = WorkoutState.practicing;
    _timeLeft = _config.keikoTime;
    _playSound(_settings.startSet);
    // _playSound(_settings.hajime);
  }

  _finish() {
    _timer?.cancel();
    _step = WorkoutState.finished;
    _timeLeft = Duration(seconds: 0);
    _playSound(_settings.endWorkout).then((p) {
      if (p == null) {
        return;
      }
      p.onPlayerCompletion.first.then((_) {
        _playSound(_settings.endWorkout);
      });
    });
  }

  get config => _config;

  get set => _set;

  get rep => _rep;

  get step => _step;

  get timeLeft => _timeLeft;

  get totalTime => _totalTime;

  get isActive => _timer != null && _timer!.isActive;
}
