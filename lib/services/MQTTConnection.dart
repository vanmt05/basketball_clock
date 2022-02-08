import 'dart:async';
import 'dart:io';

import 'package:basketball_clock/services/ClockBaseClass.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MQTTConnection extends ClockBase {
  // String _connectionStatus = 'Unknown';
  static final MQTTConnection _instance = MQTTConnection._internal();

  String? _wifiName;
  String? _wifiGateway;
  MqttServerClient? client;

  MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  final NetworkInfo _networkInfo = NetworkInfo();

  factory MQTTConnection() {
    return _instance;
  }

  MQTTConnection._internal() {
    currentQuatersClock = Duration(seconds: 0);
    currentShotClock = Duration(seconds: 0);
    resumeClock = false;
    resumeQuatersClockMinutes = 0;
    resumeQuatersClockSeconds = 0;
    resumeShotClockDuration = 0;
  }

  Future<Map<String, dynamic>> initNetworkInfo() async {
    _wifiName = await _networkInfo.getWifiName();
    _wifiGateway = await _networkInfo.getWifiGatewayIP();
    print('$_wifiGateway init');
    client = MqttServerClient('$_wifiGateway', '');
    return {'wifiName': _wifiName, 'wifiGateway': _wifiGateway};
  }

// MQTT Logic
  Future<int?> connectclient() async {
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
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
        _wifiGateway = null;
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
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    // _streamConnController.add(_client!.connectionStatus!.state);

    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    // _streamConnController.add(_client!.connectionStatus!.state);

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
    // _streamConnController.add(_client!.connectionStatus!.state);

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
    // _streamConnController.add(_client!.connectionStatus!.state);

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
