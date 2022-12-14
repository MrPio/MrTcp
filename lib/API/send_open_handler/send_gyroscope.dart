import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';

import '../web_socket_manager.dart';

class SendGyroscope extends SendOpenHandler {
  Stream<SensorEvent>? _gyroscopeStream;
  StreamSubscription<SensorEvent>? _gyroscopeStreamSubscription;

  WebSocketManager get _webSocketManager => WebSocketManager.getInstance();
  int pkgSent = 0;
  String cmdValue = 'mouse';

  @override
  initialize(Map<String, dynamic> params) async {
    super.initialize(params);
    if (params.keys.contains('value')) {
      cmdValue = params['value'];
    }
    _gyroscopeStream = await SensorManager().sensorUpdates(
      sensorId: Sensors.GYROSCOPE,
      interval: Duration(microseconds: 4000),
    );
  }

  @override
  open() async {
    super.open();
    _gyroscopeStreamSubscription =
        _gyroscopeStream?.listen((sensorEvent) {
      ++pkgSent;
      _webSocketManager.sendString(
          '${sensorEvent.data[0].toStringAsFixed(5)}:${sensorEvent.data[1].toStringAsFixed(5)}:${sensorEvent.data[2].toStringAsFixed(5)}');
    });
  }

  @override
  Map<String, dynamic> sendStart() {
    var command = {
      'type': 'command',
      'command_type': 'recv',
      'stream_type': 'open',
      'command_name': 'GYRO_RECV',
      'value': cmdValue
    };
    return command;
  }

  @override
  stop() async {
    super.stop();
    _gyroscopeStreamSubscription?.cancel();
  }
}
