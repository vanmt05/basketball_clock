import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';

class ControlButtons extends StatefulWidget {
  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  static const Duration? defaultQuatersDuration = Duration(minutes: 12);
  static const Duration? defaultShotClockDuration = Duration(seconds: 24);

  Duration? currentQuatersClockDuration = Duration();
  Duration? currentShotClockDuration = Duration();

  Timer? timer;

  bool countDown = true;
  bool? minus;
  bool? add;
  double? relativeWidthConstraints;
  double? relativeHeightConstraints;
  ButtonState? _startPauseState;
  // int? currentQuatersClockMiliSeconds;
  // int? currentQuatersClockSeconds;
  // int? currentShotClockSeconds;
  // Duration? currentShotClockSeconds;
  @override
  void initState() {
    super.initState();
    _startPauseState = ButtonState.START;
    currentQuatersClockDuration = defaultQuatersDuration;
    currentShotClockDuration = defaultShotClockDuration;
  }

  @override
  void dispose() async {
    super.dispose();
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

// Widgets
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
                startTimer();
                setState(() {
                  _startPauseState = ButtonState.PAUSE;
                });
              } else if (_startPauseState == ButtonState.PAUSE) {
                //if press and it's show PAUSE in display then pause
                stopTimer(resets: false);
                setState(() {
                  _startPauseState = ButtonState.START;
                });
              }
            },
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(
                    (_startPauseState == ButtonState.START)
                        ? Colors.red
                        : (_startPauseState == ButtonState.PAUSE)
                            ? Colors.green[600]
                            : Colors.transparent),
                elevation: MaterialStateProperty.all<double?>(10),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70.0),
                )),
                backgroundColor: MaterialStateProperty.all(
                    (_startPauseState == ButtonState.START)
                        ? Colors.green[600]
                        : (_startPauseState == ButtonState.PAUSE)
                            ? Colors.red
                            : Colors.grey[300])),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ((_startPauseState == ButtonState.START) ||
                        (_startPauseState == ButtonState.DISABLE))
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
                  child: ((_startPauseState == ButtonState.START) ||
                          (_startPauseState == ButtonState.DISABLE))
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
            onPressed: reset,
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(
                    (currentQuatersClockDuration!.inSeconds > 24)
                        ? Colors.blue[200]
                        : Colors.transparent),
                elevation: MaterialStateProperty.all<double?>(10),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70.0),
                )),
                backgroundColor: MaterialStateProperty.all(
                    (currentQuatersClockDuration!.inSeconds > 24)
                        ? Colors.blue
                        : Colors.grey[300])),
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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(currentQuatersClockDuration!.inMinutes);
    final seconds =
        twoDigits(currentQuatersClockDuration!.inSeconds.remainder(60));
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
                onPressed: addMinutes,
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Minutes
              IconButton(
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 50,
                onPressed: removeMinutes,
                icon: Icon(
                  Icons.remove_circle_outline_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SevenSegmentDisplay(
                backgroundColor: Colors.transparent,
                value: '$minutes:$seconds',
                size: 8.0,
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // (+) Seconds
              IconButton(
                disabledColor: Colors.grey[350],
                splashColor: Colors.green,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () {
                  addSeconds('quatersClock');
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
                onPressed: () {
                  removeSeconds('quatersClock');
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
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // final minutes = twoDigits(duration!.inMinutes.remainder(60));
    final seconds = twoDigits(currentShotClockDuration?.inSeconds ?? 0);
    return Expanded(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // (-) Seconds
      IconButton(
        splashColor: Colors.red,
        splashRadius: 30,
        iconSize: 80,
        onPressed: () {
          removeSeconds('shotClock');
        },
        icon: Icon(
          Icons.remove_circle_outline_outlined,
        ),
      ),
      // Display
      SevenSegmentDisplay(
        backgroundColor: Colors.transparent,
        value: '$seconds',
        size: 8.0,
      ),

      // (+) Seconds
      IconButton(
        splashColor: Colors.green,
        splashRadius: 30,
        iconSize: 80,
        onPressed: () {
          addSeconds('shotClock');
        },
        icon: Icon(
          Icons.add_circle_outline_outlined,
        ),
      ),
    ]));
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.yellow[200]),
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
              Container(
                width: 180,
                height: (relativeHeightConstraints! * 0.533) / 2,
                child: TextButton(
                  child: Text(
                    '14',
                    style: TextStyle(
                      color: ((_startPauseState == ButtonState.START ||
                                  _startPauseState == ButtonState.DISABLE) &&
                              currentQuatersClockDuration!.inSeconds > 24)
                          ? Colors.black
                          : Colors.grey,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: fourteenSeconds,
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          ((_startPauseState == ButtonState.START ||
                                      _startPauseState ==
                                          ButtonState.DISABLE) &&
                                  currentQuatersClockDuration!.inSeconds > 24)
                              ? Colors.yellow[200]
                              : Colors.transparent),
                      elevation: MaterialStateProperty.all<double?>(10),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(
                          ((_startPauseState == ButtonState.START ||
                                      _startPauseState ==
                                          ButtonState.DISABLE) &&
                                  currentQuatersClockDuration!.inSeconds > 24)
                              ? Colors.yellow[600]
                              : Colors.grey[300])),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Logic of timer buttons
  void reset() {
    if (countDown) {
      if (currentQuatersClockDuration!.inSeconds > 24) {
        setState(() {
          currentShotClockDuration = defaultShotClockDuration;
          if (_startPauseState == ButtonState.START) {
            timer!.cancel();
          } else if (_startPauseState == ButtonState.DISABLE) {
            startTimer();
            _startPauseState = ButtonState.PAUSE;
          }
        });
      }
    } else {
      setState(() {
        currentShotClockDuration = Duration();
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => countdownTime());
  }

  void addMinutes() {
    if (currentQuatersClockDuration!.inSeconds <= 660) {
      setState(() {
        final seconds = currentQuatersClockDuration!.inSeconds + 60;
        if (seconds > 720) {
          timer?.cancel();
        } else {
          currentQuatersClockDuration = Duration(seconds: seconds);
        }
      });
    } else {
      setState(() {
        final seconds = currentQuatersClockDuration!.inSeconds +
            (defaultQuatersDuration!.inSeconds -
                currentQuatersClockDuration!.inSeconds);
        currentQuatersClockDuration = Duration(seconds: seconds);
      });
    }
  }

  void removeMinutes() {
    if (currentQuatersClockDuration!.inSeconds > 60) {
      setState(() {
        final minutes = currentQuatersClockDuration!.inMinutes;
        final seconds = currentQuatersClockDuration!.inSeconds - 60;
        if (minutes < 0 && seconds < 0) {
          timer?.cancel();
        } else {
          currentQuatersClockDuration = Duration(seconds: seconds);
        }
      });
    }
  }

  void addSeconds(String clockButton) {
    // final addSeconds = minus ? -1 : 1;
    if (clockButton == 'quatersClock') {
      setState(() {
        final seconds = currentQuatersClockDuration!.inSeconds + 1;
        if (seconds > 720) {
          timer?.cancel();
        } else {
          currentQuatersClockDuration = Duration(seconds: seconds);
        }
      });
    } else if (clockButton == 'shotClock') {
      setState(() {
        final seconds = currentShotClockDuration!.inSeconds + 1;
        if (seconds > 24) {
          timer?.cancel();
        } else {
          if (_startPauseState == ButtonState.DISABLE) {
            _startPauseState = ButtonState.START;
          }

          currentShotClockDuration = Duration(seconds: seconds);
        }
      });
    }
  }

  void removeSeconds(String clockButton) {
    // final addSeconds = minus ? -1 : 1;
    if (clockButton == 'quatersClock') {
      setState(() {
        final seconds = currentQuatersClockDuration!.inSeconds - 1;
        if (seconds < 0) {
          timer?.cancel();
        } else {
          currentQuatersClockDuration = Duration(seconds: seconds);
        }
      });
    } else if (clockButton == 'shotClock') {
      setState(() {
        final seconds = currentShotClockDuration!.inSeconds - 1;
        if (seconds == 0) {
          _startPauseState = ButtonState.DISABLE;
        }
        if (seconds < 0) {
          timer?.cancel();
        } else {
          currentShotClockDuration = Duration(seconds: seconds);
        }
      });
    }
  }

  void fourteenSeconds() {
    if ((_startPauseState == ButtonState.START ||
            _startPauseState == ButtonState.DISABLE) &&
        currentQuatersClockDuration!.inSeconds > 24) {
      setState(() {
        final seconds = 14;

        if (_startPauseState == ButtonState.DISABLE) {
          _startPauseState = ButtonState.START;
        }

        currentShotClockDuration = Duration(seconds: seconds);
      });
    }
  }

  void countdownTime() {
    setState(() {
      if (currentQuatersClockDuration!.inSeconds > 24) {
        final shotClockseconds = currentShotClockDuration!.inSeconds - 1;
        final quatersClockseconds = currentQuatersClockDuration!.inSeconds - 1;

        if (quatersClockseconds < 0 || shotClockseconds < 0) {
          timer?.cancel();
          _startPauseState = ButtonState.DISABLE; //Show Start Button
        } else {
          currentShotClockDuration = Duration(seconds: shotClockseconds);
          currentQuatersClockDuration = Duration(seconds: quatersClockseconds);
        }
      } else {
        final quatersClockseconds = currentQuatersClockDuration!.inSeconds - 1;
        final shotClockseconds = 0;

        if (quatersClockseconds < 0 || shotClockseconds < 0) {
          timer?.cancel();
          _startPauseState = ButtonState.DISABLE; //Show Start Button
        } else {
          currentShotClockDuration = Duration(seconds: shotClockseconds);
          currentQuatersClockDuration = Duration(seconds: quatersClockseconds);
        }
      }
    });
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }
}

enum ButtonState { START, PAUSE, DISABLE }
