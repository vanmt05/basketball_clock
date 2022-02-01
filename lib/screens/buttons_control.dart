import 'dart:async';
// import 'dart:ui';
import 'package:basketball_clock/shared/loading.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segment_display/segment_display.dart';
import 'package:basketball_clock/services/MQTTConnection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/services.dart';

class ButtonsControl extends StatefulWidget {
  @override
  _ButtonsControlState createState() => _ButtonsControlState();
}

class _ButtonsControlState extends State<ButtonsControl> {
  final Duration defaultQuatersDuration = Duration(minutes: 12);
  final Duration defaultShotClockDuration = Duration(seconds: 24);

  Timer? timer;

  bool countDown = true;
  bool? minus;
  bool? add;
  double? relativeWidthConstraints;
  double? relativeHeightConstraints;
  ButtonState? _startPauseState = ButtonState.START;
  // WasConnected? _wasConnected = WasConnected.NEVER;
  bool soundOnOff = false;
  var wifiConnection;
  var resumeSubscription;
  MqttConnectionState? connectionStatus;
  bool isConnectedWifi = false;
  bool quatersClockOverShotClock = false;
  late MQTTConnection mqttConnection = MQTTConnection();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    //   SystemUiOverlay.bottom, //This line is used for showing the bottom bar
    // ]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    wifiConnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      // print('wifiConnection $wifiConnection');

      // Got a new connectivity status!
      if (result == ConnectivityResult.wifi) {
        // if (_wasConnected == WasConnected.NEVER) {
        mqttConnection.initNetworkInfo().then((netWorkInfo) async {
          await mqttConnection.connectclient().then((value) => setState(() {
                if (mqttConnection.client?.connectionStatus?.state ==
                    MqttConnectionState.connected) {
                  // _wasConnected = WasConnected.BEFORE;
                  isConnectedWifi = true;
                  mqttConnection.client!.updates!.listen((dynamic c) {
                    setState(() {});
                  });
                }
              }));
        });
        // }
        // if (_wasConnected == WasConnected.BEFORE) {
        //   mqttConnection.initNetworkInfo();
        //   // setState(() {
        //   //   mqttConnection.client?.autoReconnect = true;
        //   // });
        // }

      }

      if (result == ConnectivityResult.none) {
        // setState(() {
        //   mqttConnection.client?.autoReconnect = true;
        // });

        setState(() {
          isConnectedWifi = false;
          stopTimer(resets: false);
          _startPauseState = ButtonState.START;
        });
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    // print('dispose');
    wifiConnection.cancel();

    timer?.cancel();
    mqttConnection.client?.disconnect();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  @override
  Widget build(BuildContext context) {
    // print(_wasConnected);
    // print('isConnectedWifi $isConnectedWifi');

    if ((mqttConnection.client?.connectionStatus?.state ==
        MqttConnectionState.connecting)) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        final snackBar = SnackBar(
            duration: Duration(seconds: 1),
            content: Row(
              children: [
                Text(
                  'Connecting',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  width: 10,
                ),
                Loading()
              ],
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});
      });
    }
    // print(
    //     'currentQuatersClockDuration ${mqttConnection.currentQuatersClockDuration}');
    // print(
    //     'currentShotClockDuration ${mqttConnection.currentShotClockDuration}');
    // print(
    //     'resumeQuatersClockMinutes ${mqttConnection.resumeQuatersClockMinutes}');
    // print('resumeShotClockDuration ${mqttConnection.resumeShotClockDuration}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffDC330D),
        title: Text('Buttons control'),
      ),
      body: Container(
        color: Color(0xffEADCD6),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              relativeWidthConstraints =
                  constraints.maxWidth / 3; //Body divided by 3
              relativeHeightConstraints = constraints.maxHeight;

              return Container(
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                          width: relativeWidthConstraints!,
                          height: relativeHeightConstraints!,
                          child: Column(
                              children: [Spacer(), _startPauseButton()])),
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
      ),
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
              if (mqttConnection.client?.connectionStatus?.state ==
                      MqttConnectionState.connected &&
                  isConnectedWifi) {
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
              } else {
                setState(() {});
              }
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                  (mqttConnection.client?.connectionStatus?.state ==
                              MqttConnectionState.connected &&
                          isConnectedWifi)
                      ? (_startPauseState == ButtonState.START)
                          ? Colors.red
                          : (_startPauseState == ButtonState.PAUSE)
                              ? Colors.green[600]
                              : Colors.transparent
                      : Colors.transparent),
              elevation: MaterialStateProperty.all<double?>(10),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(relativeWidthConstraints! * 0.181752),
              )),
              backgroundColor: MaterialStateProperty.all(
                  (mqttConnection.client?.connectionStatus?.state ==
                              MqttConnectionState.connected &&
                          isConnectedWifi)
                      ? (_startPauseState == ButtonState.START)
                          ? Colors.green[600]
                          : (_startPauseState == ButtonState.PAUSE)
                              ? Colors.red
                              : Colors.grey[300]
                      : Colors.grey[300]),
              animationDuration: Duration(milliseconds: 3000),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (mqttConnection.client?.connectionStatus?.state ==
                            MqttConnectionState.connected &&
                        isConnectedWifi)
                    ? ((_startPauseState == ButtonState.START) ||
                            (_startPauseState == ButtonState.DISABLE))
                        ? Icon(
                            Icons.play_arrow_outlined,
                            size: relativeHeightConstraints! * 0.306748,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.pause,
                            size: relativeHeightConstraints! * 0.306748,
                            color: Colors.white,
                          )
                    : Icon(
                        Icons.play_arrow_outlined,
                        size: relativeHeightConstraints! * 0.306748,
                        color: Colors.white,
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (mqttConnection.client?.connectionStatus?.state ==
                              MqttConnectionState.connected &&
                          isConnectedWifi)
                      ? ((_startPauseState == ButtonState.START) ||
                              (_startPauseState == ButtonState.DISABLE))
                          ? Text(
                              'START',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: relativeWidthConstraints! * 0.109051,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              'PAUSE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: relativeWidthConstraints! * 0.109051,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                      : Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: relativeWidthConstraints! * 0.109051,
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
            onLongPress: () {
              if (mqttConnection.client!.connectionStatus!.state ==
                      MqttConnectionState.connected &&
                  isConnectedWifi) {
                setState(() {
                  stopTimer(resets: false);
                  mqttConnection.currentQuatersClockDuration =
                      defaultQuatersDuration;
                  mqttConnection.currentShotClockDuration =
                      defaultShotClockDuration;
                  _startPauseState = ButtonState.START;
                  mqttConnection.builder = MqttClientPayloadBuilder();
                  mqttConnection.builder.addString('true');
                  mqttConnection.client!.publishMessage("clock/cancelResume",
                      MqttQos.exactlyOnce, mqttConnection.builder.payload!);
                  //For Shot Clock
                  mqttConnection.builder = MqttClientPayloadBuilder();
                  mqttConnection.builder.addString(mqttConnection
                      .currentShotClockDuration.inSeconds
                      .toString());
                  mqttConnection.client!.publishMessage("clock/shot",
                      MqttQos.exactlyOnce, mqttConnection.builder.payload!);
                  // For Quaters Clock in minutes
                  mqttConnection.builder = MqttClientPayloadBuilder();
                  mqttConnection.builder.addString(mqttConnection
                      .currentQuatersClockDuration.inMinutes
                      .toString());
                  mqttConnection.client!.publishMessage("clock/quaters/minutes",
                      MqttQos.exactlyOnce, mqttConnection.builder.payload!);
                  // For Quaters Clock in seconds
                  mqttConnection.builder = MqttClientPayloadBuilder();
                  mqttConnection.builder.addString(mqttConnection
                      .currentQuatersClockDuration.inSeconds
                      .toString());
                  mqttConnection.client!.publishMessage("clock/quaters/seconds",
                      MqttQos.exactlyOnce, mqttConnection.builder.payload!);
                });
              } else {
                setState(() {});
              }
            },
            onPressed: () {
              if (mqttConnection.client!.connectionStatus!.state ==
                      MqttConnectionState.connected &&
                  isConnectedWifi &&
                  mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
                reset();
              } else {
                setState(() {});
              }
            },
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all((mqttConnection
                                .client?.connectionStatus?.state ==
                            MqttConnectionState.connected &&
                        isConnectedWifi)
                    ? (mqttConnection.currentQuatersClockDuration.inSeconds >
                            24)
                        ? Colors.blue[200]
                        : Colors.transparent
                    : Colors.transparent),
                elevation: MaterialStateProperty.all<double?>(10),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      relativeWidthConstraints! * 0.181752),
                )),
                backgroundColor: MaterialStateProperty.all((mqttConnection
                                .client?.connectionStatus?.state ==
                            MqttConnectionState.connected &&
                        isConnectedWifi)
                    ? (mqttConnection.currentQuatersClockDuration.inSeconds >
                            24)
                        ? Colors.blue
                        : Colors.grey[300]
                    : Colors.grey[300])),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.restart_alt_outlined,
                    size: relativeHeightConstraints! * 0.306748,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'RESET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: relativeWidthConstraints! * 0.109051,
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
    final minutes =
        twoDigits(mqttConnection.currentQuatersClockDuration.inMinutes);
    final seconds = twoDigits(
        mqttConnection.currentQuatersClockDuration.inSeconds.remainder(60));
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // (+) Minutes
              IconButton(
                disabledColor: Colors.grey[350],
                splashColor: Colors.green,
                splashRadius: 20,
                iconSize: 35,
                onPressed: () {
                  if (mqttConnection.client?.connectionStatus?.state ==
                          MqttConnectionState.connected &&
                      isConnectedWifi) {
                    addMinutes();
                  } else {
                    return null;
                  }
                },
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Minutes
              IconButton(
                disabledColor: Colors.grey[350],
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 35,
                onPressed: () {
                  if (mqttConnection.client?.connectionStatus?.state ==
                          MqttConnectionState.connected &&
                      isConnectedWifi) {
                    removeMinutes();
                  } else {
                    return null;
                  }
                },
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
                size: 5.0,
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
                iconSize: 30,
                onPressed: () {
                  if (mqttConnection.client?.connectionStatus?.state ==
                          MqttConnectionState.connected &&
                      isConnectedWifi) {
                    addSeconds('quatersClock');
                  } else {
                    setState(() {});
                  }
                },
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                ),
              ),
              // (-) Seconds
              IconButton(
                disabledColor: Colors.grey[350],
                splashColor: Colors.red,
                splashRadius: 20,
                iconSize: 30,
                onPressed: () {
                  if (mqttConnection.client?.connectionStatus?.state ==
                          MqttConnectionState.connected &&
                      isConnectedWifi) {
                    removeSeconds('quatersClock');
                  } else {
                    setState(() {});
                  }
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
    final seconds =
        twoDigits(mqttConnection.currentShotClockDuration.inSeconds);
    return Expanded(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // (-) Seconds
      IconButton(
        disabledColor: Colors.grey[350],
        splashColor: Colors.red,
        splashRadius: 30,
        iconSize: 60,
        onPressed: () {
          if (mqttConnection.client?.connectionStatus?.state ==
                  MqttConnectionState.connected &&
              isConnectedWifi &&
              mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
            removeSeconds('shotClock');
          } else {
            setState(() {});
          }
        },
        icon: Icon(
          Icons.remove_circle_outline_outlined,
        ),
      ),
      // Display
      SevenSegmentDisplay(
        backgroundColor: Colors.transparent,
        value: '$seconds',
        size: 6.0,
      ),

      // (+) Seconds
      IconButton(
        disabledColor: Colors.grey[350],
        splashColor: Colors.green,
        splashRadius: 30,
        iconSize: 60,
        onPressed: () {
          if (mqttConnection.client?.connectionStatus?.state ==
                  MqttConnectionState.connected &&
              isConnectedWifi &&
              mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
            addSeconds('shotClock');
          } else {
            setState(() {});
          }
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
                width: relativeWidthConstraints! * 0.436205,
                height: (relativeHeightConstraints! * 0.533) / 2,
                child:
                    // Sound button
                    ElevatedButton(
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          (mqttConnection.client?.connectionStatus?.state ==
                                      MqttConnectionState.connected &&
                                  isConnectedWifi)
                              ? Colors.yellow[200]
                              : Colors.grey[300]),
                      elevation: MaterialStateProperty.all<double?>(10),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            relativeWidthConstraints! * 0.065430),
                      )),
                      backgroundColor: MaterialStateProperty.all(
                          (mqttConnection.client?.connectionStatus?.state ==
                                      MqttConnectionState.connected &&
                                  isConnectedWifi)
                              ? Colors.yellow[600]
                              : Colors.grey[300])),
                  onPressed: () {
                    if (mqttConnection.client?.connectionStatus?.state ==
                            MqttConnectionState.connected &&
                        isConnectedWifi) {
                      // setState(() {
                      //   soundOnOff = !soundOnOff;
                      // });
                      mqttConnection.builder = MqttClientPayloadBuilder();
                      mqttConnection.builder.addString("1");
                      mqttConnection.client!.publishMessage("sound",
                          MqttQos.exactlyOnce, mqttConnection.builder.payload!);
                      Future.delayed(Duration(seconds: 1), () {
                        mqttConnection.builder = MqttClientPayloadBuilder();
                        mqttConnection.builder.addString("0");
                        mqttConnection.client!.publishMessage(
                            "sound",
                            MqttQos.exactlyOnce,
                            mqttConnection.builder.payload!);
                      });
                    } else {
                      setState(() {});
                    }
                  },
                  child: Icon(
                    Icons.volume_up_outlined,
                    color: (mqttConnection.client?.connectionStatus?.state ==
                                MqttConnectionState.connected &&
                            isConnectedWifi)
                        ? Colors.black
                        : Colors.grey,
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
                width: relativeWidthConstraints! * 0.436205,
                height: (relativeHeightConstraints! * 0.533) / 2,
                child: TextButton(
                  child: Text(
                    '14',
                    style: TextStyle(
                      color: (mqttConnection.client?.connectionStatus?.state ==
                                  MqttConnectionState.connected &&
                              isConnectedWifi)
                          ? ((_startPauseState == ButtonState.START ||
                                      _startPauseState ==
                                          ButtonState.DISABLE) &&
                                  mqttConnection.currentQuatersClockDuration
                                          .inSeconds >
                                      24)
                              ? Colors.black
                              : Colors.grey
                          : Colors.grey,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (mqttConnection.client?.connectionStatus?.state ==
                            MqttConnectionState.connected &&
                        isConnectedWifi) {
                      fourteenSeconds();
                    } else {
                      setState(() {});
                    }
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all((mqttConnection
                                      .client?.connectionStatus?.state ==
                                  MqttConnectionState.connected &&
                              isConnectedWifi)
                          ? ((_startPauseState == ButtonState.START || _startPauseState == ButtonState.DISABLE) &&
                                  mqttConnection.currentQuatersClockDuration.inSeconds >
                                      24)
                              ? Colors.yellow[200]
                              : Colors.transparent
                          : Colors.transparent),
                      elevation: MaterialStateProperty.all<double?>(10),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            relativeWidthConstraints! * 0.065430),
                      )),
                      backgroundColor: MaterialStateProperty.all(
                          (mqttConnection.client?.connectionStatus?.state == MqttConnectionState.connected &&
                                  isConnectedWifi)
                              ? ((_startPauseState == ButtonState.START ||
                                          _startPauseState == ButtonState.DISABLE) &&
                                      mqttConnection.currentQuatersClockDuration.inSeconds > 24)
                                  ? Colors.yellow[600]
                                  : Colors.grey[300]
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
      if (mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
        setState(() {
          mqttConnection.currentShotClockDuration = defaultShotClockDuration;
          //For Shot Clock
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentShotClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/shot",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          if (_startPauseState == ButtonState.PAUSE) {
            timer!.cancel();
            _startPauseState = ButtonState.START;
          } else if (_startPauseState == ButtonState.DISABLE) {
            startTimer();
            _startPauseState = ButtonState.PAUSE;
          }
        });
      }
    } else {
      setState(() {
        mqttConnection.currentShotClockDuration = defaultShotClockDuration;
        //For Shot Clock
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder
            .addString(mqttConnection.currentShotClockDuration.toString());
        mqttConnection.client!.publishMessage(
            "clock/shot", MqttQos.exactlyOnce, mqttConnection.builder.payload!);
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => countdownTime());
  }

  void addMinutes() {
    if (mqttConnection.currentQuatersClockDuration.inSeconds <= 660) {
      setState(() {
        final seconds =
            mqttConnection.currentQuatersClockDuration.inSeconds + 60;
        if (seconds > 720) {
          timer?.cancel();
        } else {
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: seconds);
          // For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    } else {
      setState(() {
        final seconds = mqttConnection.currentQuatersClockDuration.inSeconds +
            (defaultQuatersDuration.inSeconds -
                mqttConnection.currentQuatersClockDuration.inSeconds);
        mqttConnection.currentQuatersClockDuration = Duration(seconds: seconds);
        // For Quaters Clock in minutes
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inMinutes.toString());
        mqttConnection.client!.publishMessage("clock/quaters/minutes",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        // For Quaters Clock in seconds
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage("clock/quaters/seconds",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);
      });
    }
  }

  void removeMinutes() {
    if (mqttConnection.currentQuatersClockDuration.inSeconds > 60) {
      setState(() {
        final minutes = mqttConnection.currentQuatersClockDuration.inMinutes;
        final seconds =
            mqttConnection.currentQuatersClockDuration.inSeconds - 60;
        if (minutes < 0 && seconds < 0) {
          timer?.cancel();
        } else {
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: seconds);
          // For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    }
  }

  void addSeconds(String clockButton) {
    // final addSeconds = minus ? -1 : 1;
    if (clockButton == 'quatersClock') {
      setState(() {
        final seconds =
            mqttConnection.currentQuatersClockDuration.inSeconds + 1;
        if (seconds > 720) {
          timer?.cancel();
        } else {
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: seconds);
          // For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    } else if (clockButton == 'shotClock') {
      setState(() {
        final seconds = mqttConnection.currentShotClockDuration.inSeconds + 1;
        if (seconds > 24) {
          timer?.cancel();
        } else {
          if (_startPauseState == ButtonState.DISABLE) {
            _startPauseState = ButtonState.START;
          }

          mqttConnection.currentShotClockDuration = Duration(seconds: seconds);
          //For Shot Clock
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentShotClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/shot",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    }
  }

  void removeSeconds(String clockButton) {
    // final addSeconds = minus ? -1 : 1;
    if (clockButton == 'quatersClock') {
      setState(() {
        final seconds =
            mqttConnection.currentQuatersClockDuration.inSeconds - 1;
        if (seconds < 0) {
          timer?.cancel();
        } else {
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: seconds);

          /// For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    } else if (clockButton == 'shotClock') {
      setState(() {
        final seconds = mqttConnection.currentShotClockDuration.inSeconds - 1;
        if (seconds == 0) {
          _startPauseState = ButtonState.DISABLE;
        }
        if (seconds < 0) {
          timer?.cancel();
        } else {
          mqttConnection.currentShotClockDuration = Duration(seconds: seconds);
          //For Shot Clock
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentShotClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/shot",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
      });
    }
  }

  void fourteenSeconds() {
    if ((_startPauseState == ButtonState.START ||
            _startPauseState == ButtonState.DISABLE) &&
        mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
      setState(() {
        final seconds = 14;

        if (_startPauseState == ButtonState.DISABLE) {
          _startPauseState = ButtonState.START;
        }
        // mqttConnection.resumeShotClockDuration = seconds;
        mqttConnection.currentShotClockDuration = Duration(seconds: seconds);
        //For Shot Clock
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentShotClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage(
            "clock/shot", MqttQos.exactlyOnce, mqttConnection.builder.payload!);
      });
    }
  }

  void countdownTime() {
    setState(() {
      if (mqttConnection.currentQuatersClockDuration.inSeconds > 24) {
        final shotClockseconds =
            (mqttConnection.currentShotClockDuration.inSeconds > 0)
                ? mqttConnection.currentShotClockDuration.inSeconds - 1
                : 0;
        final quatersClockseconds =
            (mqttConnection.currentQuatersClockDuration.inSeconds > 0)
                ? mqttConnection.currentQuatersClockDuration.inSeconds - 1
                : 0;

        if (mqttConnection.currentShotClockDuration.inSeconds == 0) {
          timer?.cancel();

          _startPauseState = ButtonState.START; //Show Start Button

        } else {
          mqttConnection.currentShotClockDuration =
              Duration(seconds: shotClockseconds);
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: quatersClockseconds);
          //For Shot Clock
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentShotClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/shot",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
        return;
      }

      if (mqttConnection.currentQuatersClockDuration.inSeconds <= 24 &&
          mqttConnection.currentShotClockDuration.inSeconds > 0) {
        final shotClockseconds =
            (mqttConnection.currentShotClockDuration.inSeconds > 0)
                ? mqttConnection.currentShotClockDuration.inSeconds - 1
                : 0;
        final quatersClockseconds =
            (mqttConnection.currentQuatersClockDuration.inSeconds > 0)
                ? mqttConnection.currentQuatersClockDuration.inSeconds - 1
                : 0;

        if (shotClockseconds == 0) {
          timer?.cancel();
          _startPauseState = ButtonState.START; //Show Start Button
        }
        mqttConnection.currentShotClockDuration =
            Duration(seconds: shotClockseconds);
        mqttConnection.currentQuatersClockDuration =
            Duration(seconds: quatersClockseconds);
        //For Shot Clock
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentShotClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage(
            "clock/shot", MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        // For Quaters Clock in minutes
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inMinutes.toString());
        mqttConnection.client!.publishMessage("clock/quaters/minutes",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        // For Quaters Clock in seconds
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage("clock/quaters/seconds",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);

        return;
      }
      if (mqttConnection.currentQuatersClockDuration.inSeconds == 24 &&
          mqttConnection.currentShotClockDuration.inSeconds == 0) {
        final shotClockseconds = 0;
        final quatersClockseconds =
            mqttConnection.currentQuatersClockDuration.inSeconds - 1;
        if (!quatersClockOverShotClock) {
          timer?.cancel();
          _startPauseState = ButtonState.START; //Show Start Button
        } else {
          mqttConnection.currentShotClockDuration =
              Duration(seconds: shotClockseconds);
          mqttConnection.currentQuatersClockDuration =
              Duration(seconds: quatersClockseconds);
          //For Shot Clock
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentShotClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/shot",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in minutes
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inMinutes.toString());
          mqttConnection.client!.publishMessage("clock/quaters/minutes",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
          // For Quaters Clock in seconds
          mqttConnection.builder = MqttClientPayloadBuilder();
          mqttConnection.builder.addString(
              mqttConnection.currentQuatersClockDuration.inSeconds.toString());
          mqttConnection.client!.publishMessage("clock/quaters/seconds",
              MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        }
        quatersClockOverShotClock = !quatersClockOverShotClock;
        return;
      }
      if (mqttConnection.currentQuatersClockDuration.inSeconds < 24 &&
          mqttConnection.currentShotClockDuration.inSeconds == 0) {
        final shotClockseconds = 0;
        final quatersClockseconds =
            mqttConnection.currentQuatersClockDuration.inSeconds - 1;

        if (quatersClockseconds == 0) {
          timer?.cancel();
          _startPauseState = ButtonState.DISABLE; //Disable Start Button
        }
        mqttConnection.currentShotClockDuration =
            Duration(seconds: shotClockseconds);
        mqttConnection.currentQuatersClockDuration =
            Duration(seconds: quatersClockseconds);
        //For Shot Clock
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentShotClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage(
            "clock/shot", MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        // For Quaters Clock in minutes
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inMinutes.toString());
        mqttConnection.client!.publishMessage("clock/quaters/minutes",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);
        // For Quaters Clock in seconds
        mqttConnection.builder = MqttClientPayloadBuilder();
        mqttConnection.builder.addString(
            mqttConnection.currentQuatersClockDuration.inSeconds.toString());
        mqttConnection.client!.publishMessage("clock/quaters/seconds",
            MqttQos.exactlyOnce, mqttConnection.builder.payload!);

        return;
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
enum WasConnected { NEVER, BEFORE }
