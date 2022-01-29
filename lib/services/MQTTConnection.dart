import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MQTTConnection {
  // String _connectionStatus = 'Unknown';
  String? wifiName;
  String? wifiGateway;
  MqttServerClient? client;
  Duration currentQuatersClockDuration = Duration(seconds: 0);
  Duration currentShotClockDuration = Duration(seconds: 0);
  int? resumeQuatersClockMinutes = 0;
  int? resumeQuatersClockSeconds = 0;
  int? resumeShotClockDuration = 0;

  bool resumeClock = false;

  MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  final NetworkInfo _networkInfo = NetworkInfo();
  StreamController<MqttConnectionState> _streamConnController =
      StreamController();

  Stream<MqttConnectionState> get streamConn => _streamConnController.stream;

  MQTTConnection();

  Future<Map<String, dynamic>> initNetworkInfo() async {
    wifiName = await _networkInfo.getWifiName();
    wifiGateway = await _networkInfo.getWifiGatewayIP();
    print('$wifiGateway init');
    client = MqttServerClient('$wifiGateway', '');
    return {'wifiName': wifiName, 'wifiGateway': wifiGateway};
  }

// MQTT Logic
  Future<int?> connectclient() async {
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    // client!.autoReconnect = true;
    client!.onAutoReconnect = onAutoReconnect;
    client!.onAutoReconnected = onAutoReconnected;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Android1')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } on SocketException catch (e) {
      print('Error: ${e.osError!.message}');
      if (e.osError!.message == "Connection refused") {
        wifiGateway = null;
      } else if (e.osError!.message == "Software caused connection abort") {}
      client!.disconnect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client!.disconnect();
    } catch (e) {
      print('Error: $e');
      client!.disconnect();
      return null;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');

      /// Lets try our subscriptions
      // print('EXAMPLE:: <<<< SUBSCRIBE 1 >>>>');
      const topic1 = 'resume/resumeClock'; // Not a wildcard topic
      client!.subscribe(topic1, MqttQos.atLeastOnce);
      // print('EXAMPLE:: <<<< SUBSCRIBE 2 >>>>');
      const topic2 = 'resume/shot'; // Not a wildcard topic
      client!.subscribe(topic2, MqttQos.atLeastOnce);
      const topic3 =
          'resume/quaters/minutes'; // Not a wildcard topic - no subscription
      client!.subscribe(topic3, MqttQos.atLeastOnce);
      const topic4 =
          'resume/quaters/seconds'; // Not a wildcard topic - no subscription
      client!.subscribe(topic4, MqttQos.atLeastOnce);
      // print(netWorkInfo['wifiName']);
      client!.updates!.listen((dynamic c) {
        final MqttPublishMessage recMess = c[0].payload;
        final pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        if (c[0].topic == "resume/resumeClock" && pt == "true") {
          // resumeClock = true;
        }
        if (c[0].topic == "resume/resumeClock" && pt == "false") {
          // resumeClock = false;
        }
        // if (resumeClock) {
        if (c[0].topic == "resume/shot") {
          resumeShotClockDuration = int.parse(pt);
          currentShotClockDuration =
              Duration(seconds: resumeShotClockDuration!);
        }
        if (c[0].topic == "resume/quaters/minutes") {
          resumeQuatersClockMinutes = int.parse(pt);
          currentQuatersClockDuration =
              Duration(minutes: resumeQuatersClockMinutes!);
        }
        if (c[0].topic == "resume/quaters/seconds") {
          resumeQuatersClockSeconds = int.parse(pt);
          currentQuatersClockDuration = Duration(
              minutes: currentQuatersClockDuration.inMinutes,
              seconds: resumeQuatersClockSeconds!);
          // }
        }

        // For Quaters Clock
        // if (currentQuatersClockDuration >
        //     Duration(
        //         minutes: resumeQuatersClockMinutes!,
        //         seconds: resumeQuatersClockSeconds!)) {
        //   currentQuatersClockDuration = currentQuatersClockDuration;
        // } else {
        //   currentQuatersClockDuration = Duration(
        //       minutes: resumeQuatersClockMinutes!,
        //       seconds: resumeQuatersClockSeconds!);
        // }

        //For Shot Clock
        // currentShotClockDuration = currentShotClockDuration >
        //         Duration(seconds: resumeShotClockDuration!)
        //     ? currentShotClockDuration
        //     : Duration(seconds: resumeShotClockDuration!);

        if (currentQuatersClockDuration > Duration(seconds: 0) &&
            currentShotClockDuration > Duration(seconds: 0)) {
          builder = MqttClientPayloadBuilder();
          builder.addString('true');
          client!.publishMessage(
              "clock/cancelResume", MqttQos.exactlyOnce, builder.payload!);
          // For Quaters Clock in minutes
          builder = MqttClientPayloadBuilder();
          builder.addString(currentQuatersClockDuration.inMinutes.toString());
          client!.publishMessage(
              "clock/quaters/minutes", MqttQos.exactlyOnce, builder.payload!);
          // For Quaters Clock in seconds
          builder = MqttClientPayloadBuilder();
          builder.addString(currentQuatersClockDuration.inSeconds.toString());
          client!.publishMessage(
              "clock/quaters/seconds", MqttQos.exactlyOnce, builder.payload!);
          //For Shot Clock
          builder = MqttClientPayloadBuilder();
          builder.addString(currentShotClockDuration.inSeconds.toString());
          client!.publishMessage(
              "clock/shot", MqttQos.exactlyOnce, builder.payload!);
          // print("clock/cancelResume");
        } else if (currentQuatersClockDuration > Duration(seconds: 0) &&
            currentShotClockDuration == Duration(seconds: 0)) {
          builder = MqttClientPayloadBuilder();
          builder.addString('true');
          client!.publishMessage(
              "clock/cancelResume", MqttQos.exactlyOnce, builder.payload!);
          // For Quaters Clock in minutes
          builder = MqttClientPayloadBuilder();
          builder.addString(currentQuatersClockDuration.inMinutes.toString());
          client!.publishMessage(
              "clock/quaters/minutes", MqttQos.exactlyOnce, builder.payload!);
          // For Quaters Clock in seconds
          builder = MqttClientPayloadBuilder();
          builder.addString(currentQuatersClockDuration.inSeconds.toString());
          client!.publishMessage(
              "clock/quaters/seconds", MqttQos.exactlyOnce, builder.payload!);
        }
        print('currentQuatersClockDuration $currentQuatersClockDuration');
        print('currentShotClockDuration $currentShotClockDuration');
        // print(
        //     'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
        // print('');
      });
    } else {
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client!.connectionStatus}');
      client!.disconnect();
      // ignore: unnecessary_statements

      // exit(-1);
    }

    //For Shot Clock
    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentShotClockDuration.inSeconds.toString());
    // client!.publishMessage("clock/shot", MqttQos.atLeastOnce, builder.payload!);
    // // For Quaters Clock in minutes
    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentQuatersClockDuration.inMinutes.toString());
    // client!.publishMessage(
    //     "clock/quaters/minutes", MqttQos.atLeastOnce, builder.payload!);
    // // For Quaters Clock in seconds
    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentQuatersClockDuration.inSeconds.toString());
    // client!.publishMessage(
    //     "clock/quaters/seconds", MqttQos.atLeastOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    _streamConnController.add(client!.connectionStatus!.state);

    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    _streamConnController.add(client!.connectionStatus!.state);

    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.values[0]) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    // wifiGateway = null;

    // exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    _streamConnController.add(client!.connectionStatus!.state);

    // if (resumeClock) {
    // print('resumeClock');

    // // For false resume
    // builder = MqttClientPayloadBuilder();
    // builder.addString("false");
    // client!.publishMessage(
    //     "clock/cancelResume", MqttQos.exactlyOnce, builder.payload!);
    // // For Quaters Clock in minutes
    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentQuatersClockDuration.inMinutes.toString());
    // client!.publishMessage(
    //     "clock/quaters/minutes", MqttQos.exactlyOnce, builder.payload!);
    // // For Quaters Clock in seconds
    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentQuatersClockDuration.inSeconds.toString());
    // client!.publishMessage(
    //     "clock/quaters/seconds", MqttQos.exactlyOnce, builder.payload!);

    // builder = MqttClientPayloadBuilder();
    // builder.addString(currentShotClockDuration.inSeconds.toString());
    // client!.publishMessage("clock/shot", MqttQos.exactlyOnce, builder.payload!);
    // resumeClock = false;
    // } else {
    //   print('No resumeClock');

    //   //For Shot Clock
    //   builder = MqttClientPayloadBuilder();
    //   builder.addString(currentShotClockDuration.inSeconds.toString());
    //   client!
    //       .publishMessage("clock/shot", MqttQos.atLeastOnce, builder.payload!);
    //   // For Quaters Clock in minutes
    //   builder = MqttClientPayloadBuilder();
    //   builder.addString(currentQuatersClockDuration.inMinutes.toString());
    //   client!.publishMessage(
    //       "clock/quaters/minutes", MqttQos.atLeastOnce, builder.payload!);
    //   // For Quaters Clock in seconds
    //   builder = MqttClientPayloadBuilder();
    //   builder.addString(currentQuatersClockDuration.inSeconds.toString());
    //   client!.publishMessage(
    //       "clock/quaters/seconds", MqttQos.atLeastOnce, builder.payload!);
    // }
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
    // while (client!.connectionStatus!.state == MqttConnectionState.connected) {}
    // print(_connectionStatus);
  }

  void onAutoReconnect() {
    _streamConnController.add(client!.connectionStatus!.state);

    print(
        'EXAMPLE::onAutoReconnect client callback - Client auto reconnection sequence will start');
  }

  void onAutoReconnected() {
    print(
        'EXAMPLE::onAutoReconnected client callback - Client auto reconnection sequence has completed');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }
}
