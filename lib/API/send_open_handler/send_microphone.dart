import 'package:camera/camera.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';
import 'package:mr_tcp/hardware/microphone/microphone_manager.dart';
import 'package:mr_tcp/hardware/webcam/webcam_manger.dart';

class SendMicrophone extends SendOpenHandler {
  MicrophoneManager get _microphoneManager => MicrophoneManager.getInstance();

/*  @override
  initialize(Map<String, dynamic> params) async {
    super.initialize(params);
  }*/

  @override
  open() {
    super.open();
    _microphoneManager.open();
  }

  @override
  Map<String, dynamic> sendStart() {
    var command = {
      'type': 'command',
      'command_type': 'recv',
      'stream_type': 'open',
      'command_name': 'MIC_RECV'
    };
    return command;
  }

  @override
  stop() async {
    super.stop();
    await _microphoneManager.close();
  }
}
