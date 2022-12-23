import 'package:camera/camera.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';
import 'package:mr_tcp/hardware/webcam/webcam_manger.dart';

class SendWebcam extends SendOpenHandler {
  static ResolutionPreset resolutionPreset=ResolutionPreset.medium;
  WebcamManager get _webcamManager => WebcamManager.getInstance();

  @override
  initialize(Map<String, dynamic> params) async {
    super.initialize(params);
    var cameras = await availableCameras();
    // final resolution = ResolutionPreset.values
    //     .firstWhere((e) => e.name == params['resolution']);

    _webcamManager.cameraController =
        CameraController(cameras[params['camera']], resolutionPreset);
  }

  @override
  open() {
    super.open();
    _webcamManager.open();
  }

  @override
  Map<String, dynamic> sendStart() {
    var command = {
      'type': 'command',
      'command_type': 'recv',
      'stream_type': 'open',
      'command_name': 'WEBCAM_RECV'
    };
    return command;
  }

  @override
  stop() async {
    super.stop();
    await _webcamManager.close();
  }
}
