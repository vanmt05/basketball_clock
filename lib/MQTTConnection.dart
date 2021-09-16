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
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
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
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
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
      // exit(-1);
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.values[0]) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    wifiGateway = null;

    // exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
    // print(_connectionStatus);
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }
}
