import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// import 'MQTTConnection.dart';

class Loading extends StatefulWidget {
  // final MQTTConnection mqttConnection;
  // Loading(this.mqttConnection);
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: SpinKitChasingDots(
              color: Colors.black,
              size: 150.0,
            ),
          ),
        ),
      ),
    );
  }
}
