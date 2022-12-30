import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';

import '../web_socket_manager.dart';

class SendAccelerometer extends SendOpenHandler {
  Stream<SensorEvent>? _accelerometerStream;
  StreamSubscription<SensorEvent>? _accelerometerStreamSubscription;

  WebSocketManager get _webSocketManager => WebSocketManager.getInstance();
  int pkgSent = 0;
  String cmdValue = 'mouse';

  @override
  initialize(Map<String, dynamic> params) async {
    super.initialize(params);
    if (params.keys.contains('value')) {
      cmdValue = params['value'];
    }
    _accelerometerStream = await SensorManager().sensorUpdates(
      sensorId: Sensors.LINEAR_ACCELERATION,
      interval: Duration(microseconds: 16000),
    );
  }

  @override
  open() async {
    super.open();
    _accelerometerStreamSubscription =
        _accelerometerStream?.listen((sensorEvent) {
          ++pkgSent;
          _webSocketManager.sendString(
              '${sensorEvent.data[0].toStringAsFixed(2)}:${sensorEvent.data[1].toStringAsFixed(2)}:${sensorEvent.data[2].toStringAsFixed(2)}'
          );
        });
  }

  @override
  Map<String, dynamic> sendStart() {
    var command = {
      'type': 'command',
      'command_type': 'recv',
      'stream_type': 'open',
      'command_name': 'ACC_RECV',
      'value': cmdValue
    };
    return command;
  }

  @override
  stop() async {
    super.stop();
    _accelerometerStreamSubscription?.cancel();
  }
}
