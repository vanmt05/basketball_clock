import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    return Container(
      width: 20,
      height: 20,
      child: Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Linear progress indicator',
        ),
      ),
    );
  }
}
