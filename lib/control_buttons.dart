import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:segment_display/segment_display.dart';

class ControlButtons extends StatefulWidget {
  const ControlButtons({Key? key}) : super(key: key);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  double? relativeWidthConstraints;
  double? relativeHeightConstraints;
  ButtonState? _startPauseState;
  int? currentQuatersClockMiliSeconds;
  int? currentQuatersClockSeconds;
  int? currentShotClockSeconds;

  final StopWatchTimer _quatersClockTimer =
      StopWatchTimer(mode: StopWatchMode.countDown, presetMillisecond: 720000);
  final StopWatchTimer _shotClockTimer =
      StopWatchTimer(mode: StopWatchMode.countDown, presetMillisecond: 24000);

  @override
  void initState() {
    super.initState();
    _startPauseState = ButtonState.START;
    // _quatersClockTimer.rawTime.listen((value) {
    //   // print(value);
    //   currentQuatersClockMiliSeconds = value;
    // });
    // _quatersClockTimer.secondTime.listen((value) {
    //   currentQuatersClockSeconds = value;
    // });
    // _shotClockTimer.secondTime.listen((value) {
    //   currentShotClockSeconds = value;
    // });
  }

  @override
  void dispose() async {
    super.dispose();
    await _quatersClockTimer.dispose();
    await _shotClockTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Buttons'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            relativeWidthConstraints =
                constraints.maxWidth / 3; //For body divided by 3
            relativeHeightConstraints = constraints.maxHeight;

            return Container(
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                        width: relativeWidthConstraints!,
                        height: relativeHeightConstraints!,
                        child:
                            Column(children: [Spacer(), _startPauseButton()])),
                  ),
                  Flexible(
                    child: Container(
                      width: relativeWidthConstraints,
                      child: Column(
                        children: [
                          _quatersClockWidget(),
                          _shotClockWidget(),
                          _soundFourteenSecondsWidget(),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                        width: relativeWidthConstraints!,
                        height: relativeHeightConstraints!,
                        child: Column(children: [
                          Spacer(),
                          _resetButton(),
                        ])),
                  ),
                ],
              ),
            );
          })),
    );
  }

  Widget _startPauseButton() {
    return Padding(
      padding: EdgeInsets.only(right: relativeWidthConstraints! * 0.237),
      child: Container(
          width: relativeWidthConstraints! * 0.83,
          height: relativeHeightConstraints! * 0.533,
          child: TextButton(
            onPressed: () async {
              if (_startPauseState == ButtonState.START) {
                //if press and it's show START in display then run
                _quatersClockTimer.onExecute.add(StopWatchExecute.start);
                _shotClockTimer.onExecute.add(StopWatchExecute.start);
                setState(() {
                  _startPauseState = ButtonState.PAUSE;
                });
              } else if (_startPauseState == ButtonState.PAUSE) {
                //if press and it's show PAUSE in display then pause
                _quatersClockTimer.onExecute.add(StopWatchExecute.stop);
                _shotClockTimer.onExecute.add(StopWatchExecute.stop);

                setState(() {
                  _startPauseState = ButtonState.START;
                });
              }
            },
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(
                    (_startPauseState == ButtonState.START)
                        ? Colors.red
                        : Colors.green[600]),
                elevation: MaterialStateProperty.all<double?>(10),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70.0),
                )),
                backgroundColor: MaterialStateProperty.all(
                    (_startPauseState == ButtonState.START)
                        ? Colors.green[600]
                        : Colors.red)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (_startPauseState == ButtonState.START)
                    ? Icon(
                        Icons.play_arrow_outlined,
                        size: 150,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.pause,
                        size: 150,
                        color: Colors.white,
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (_startPauseState == ButtonState.START)
                      ? Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          'PAUSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
              ],
            ),
          )),
    );
  }

  Widget _resetButton() {
    return Padding(
      padding: EdgeInsets.only(left: relativeWidthConstraints! * 0.237),
      child: Container(
          width: relativeWidthConstraints! * 0.83,
          height: relativeHeightConstraints! * 0.533,
          child: TextButton(
            onPressed: () {
              if (_startPauseState == ButtonState.START) {
                _shotClockTimer.onExecute.add(StopWatchExecute.reset);
              } else {
                _shotClockTimer.onExecute.add(StopWatchExecute.reset);
                //                     Reset and
                _shotClockTimer.onExecute
                    .add(StopWatchExecute.start); // continue counting.
              }
              // _quatersClockTimer.initialPresetTime;
              // _shotClockTimer.initialPresetTime;
            },
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                elevation: MaterialStateProperty.all<double?>(10),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.restart_alt_outlined,
                    size: 150,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'RESET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget _quatersClockWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // (+) Minutes
              IconButton(
                splashColor: Colors.green,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {
                  _quatersClockTimer.onExecute.add(StopWatchExecute.stop);
                  (_quatersClockTimer.rawTime.value <= 660000)
                      ? _quatersClockTimer.setPresetMinuteTime(1)
                      : _quatersClockTimer.setPresetMinuteTime(0);
                  print(_quatersClockTimer.rawTime.value);
                  _quatersClockTimer.onExecute.add(StopWatchExecute.start);
                },
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Minutes
              IconButton(
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {
                  print(_quatersClockTimer.rawTime.value);
                  (_quatersClockTimer.rawTime.value > 0)
                      ? _quatersClockTimer.setPresetMinuteTime(-1)
                      : _quatersClockTimer.setPresetMinuteTime(0);
                },
                icon: Icon(
                  Icons.remove_circle_outline_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              StreamBuilder<int>(
                stream: _quatersClockTimer.rawTime,
                initialData: _quatersClockTimer.rawTime.value,
                builder: (context, snap) {
                  final value = snap.data!;
                  final displayTime = StopWatchTimer.getDisplayTime(value,
                      hours: false,
                      minute: true,
                      second: true,
                      milliSecond: false);
                  return SevenSegmentDisplay(
                    backgroundColor: Colors.transparent,
                    value: '$displayTime',
                    size: 8.0,
                  );
                },
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // (+) Seconds
              IconButton(
                splashColor: Colors.green,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {
                  print(_quatersClockTimer.rawTime.value);
                  (_quatersClockTimer.rawTime.value < 720000)
                      ? _quatersClockTimer.setPresetSecondTime(1)
                      : _quatersClockTimer.setPresetSecondTime(0);
                },
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Seconds
              IconButton(
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {
                  print(_quatersClockTimer.secondTime.value);
                  (_quatersClockTimer.secondTime.value >= 0)
                      ? _quatersClockTimer.setPresetSecondTime(-1)
                      : _quatersClockTimer.setPresetSecondTime(0);
                },
                icon: Icon(
                  Icons.remove_circle_outline_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shotClockWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // (-) Seconds
          IconButton(
            splashColor: Colors.red,
            splashRadius: 30,
            iconSize: 80,
            onPressed: () async {
              _quatersClockTimer.secondTime.listen((value) {
                print(value);
              });

              if (_startPauseState == ButtonState.PAUSE) {
                _shotClockTimer.onExecute.add(StopWatchExecute.stop);
                (_shotClockTimer.secondTime.value > 0)
                    ? _shotClockTimer.setPresetTime(mSec: -1000)
                    : _shotClockTimer.setPresetTime(mSec: 0);
                // print(_shotClockTimer.secondTime.value);
                _shotClockTimer.onExecute.add(StopWatchExecute.start);
              } else {
                (_shotClockTimer.secondTime.value > 0)
                    ? _shotClockTimer.setPresetTime(mSec: -1000)
                    : _shotClockTimer.setPresetTime(mSec: 0);
                // print(_shotClockTimer.secondTime.value);
              }
            },
            icon: Icon(
              Icons.remove_circle_outline_outlined,
            ),
          ),
          // Display
          StreamBuilder<int>(
            stream: _shotClockTimer.rawTime,
            initialData: 0,
            builder: (context, snap) {
              final value = snap.data!;
              final displayTime = StopWatchTimer.getDisplayTime(value,
                  hours: false,
                  minute: false,
                  second: true,
                  milliSecond: false);
              return SevenSegmentDisplay(
                backgroundColor: Colors.transparent,
                value: '$displayTime',
                size: 8.0,
              );
            },
          ),
          // (+) Seconds
          IconButton(
            splashColor: Colors.green,
            splashRadius: 30,
            iconSize: 80,
            onPressed: () async {
              if (_startPauseState == ButtonState.PAUSE) {
                _shotClockTimer.onExecute.add(StopWatchExecute.stop);

                (_shotClockTimer.secondTime.value < 24)
                    ? _shotClockTimer.setPresetTime(mSec: 1000)
                    : _shotClockTimer.setPresetTime(mSec: 0);
                // print(_shotClockTimer.secondTime.value);
                _shotClockTimer.onExecute.add(StopWatchExecute.start);
              } else {
                (_shotClockTimer.secondTime.value < 24)
                    ? _shotClockTimer.setPresetTime(mSec: 1000)
                    : _shotClockTimer.setPresetTime(mSec: 0);
                // print(_shotClockTimer.secondTime.value);
              }
            },
            icon: Icon(
              Icons.add_circle_outline_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _soundFourteenSecondsWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: (relativeHeightConstraints! * 0.533) / 2,
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double?>(10),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.yellow[600])),
                  onPressed: () {},
                  child: Icon(
                    Icons.volume_up_outlined,
                    color: Colors.black,
                    size: 80,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 30,
                color: Colors.yellow[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: Container(
                  width: 180,
                  height: (relativeHeightConstraints! * 0.533) / 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('14',
                          style: TextStyle(fontSize: 50, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum ButtonState { START, PAUSE, RESET }
