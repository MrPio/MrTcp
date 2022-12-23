import 'package:camera/camera.dart';
import 'package:mr_tcp/API/command/command.dart';
import 'package:mr_tcp/API/web_socket_manager.dart';
import '../../hardware/webcam/webcam_manger.dart';
import '../send_open_handler/send_webcam.dart';

class WebcamResolution extends Command {
  WebcamManager get _webcamManager => WebcamManager.getInstance();

  WebSocketManager get _webSocketManager => WebSocketManager.getInstance();

  @override
  execute(Map<String, dynamic> cmd) async {
    super.execute(cmd);
    var cam = _webcamManager.cameraController;
    if (cam == null) {
      return;
    }
    SendWebcam.resolutionPreset =
        ResolutionPreset.values.firstWhere((e) => cmd['value'] == e.name);
    var cameras = await availableCameras();
    var index = cameras.indexOf(cam.description);

    await _webSocketManager.closeStream({
      'type': 'command',
      'command_name': 'WEBCAM_RECV',
      'stop': 'true',
    });
    await _webSocketManager.openStream({
      'command_name': 'WEBCAM_SEND',
      'camera': index,
    });
  }
}
