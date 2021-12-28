import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MQTTConnection {
  // String _connectionStatus = 'Unknown';
  String? wifiGateway;
  MqttServerClient? client;
  Duration currentQuatersClockDuration;
  Duration currentShotClockDuration;
  MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  final NetworkInfo _networkInfo = NetworkInfo();
  StreamController<MqttConnectionState> _streamConnController =
      StreamController();

  Stream<MqttConnectionState> get streamConn => _streamConnController.stream;

  MQTTConnection(
      this.currentQuatersClockDuration, this.currentShotClockDuration);

  Future<String?> initNetworkInfo() async {
    var getWifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    wifiGateway = getWifiGatewayIP;
    print('$wifiGateway init');
    client = MqttServerClient('$wifiGateway', '');
    return getWifiGatewayIP;
  }

// MQTT Logic
  Future<int?> connectclient() async {
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
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
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
      //For Shot Clock
      builder = MqttClientPayloadBuilder();
      builder.addString(currentShotClockDuration.inSeconds.toString());
      client!
          .publishMessage("clock/shot", MqttQos.exactlyOnce, builder.payload!);
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

    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
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
