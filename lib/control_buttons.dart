import 'dart:ui';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _startPauseState = ButtonState.START;
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

                setState(() {
                  _startPauseState = ButtonState.PAUSE;
                });
              } else if (_startPauseState == ButtonState.PAUSE) {
                //if press and it's show PAUSE in display then pause

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
              } else {}
            },
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.blue[200]),
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
                onPressed: () async {},
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Minutes
              IconButton(
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {},
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
                value: '12:00',
                size: 8.0,
              )
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
                onPressed: () async {},
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Seconds
              IconButton(
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 50,
                onPressed: () async {},
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
            onPressed: () async {},
            icon: Icon(
              Icons.remove_circle_outline_outlined,
            ),
          ),
          // Display
          SevenSegmentDisplay(
            backgroundColor: Colors.transparent,
            value: '24',
            size: 8.0,
          ),

          // (+) Seconds
          IconButton(
            splashColor: Colors.green,
            splashRadius: 30,
            iconSize: 80,
            onPressed: () async {},
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
                      color: Colors.black,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
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
