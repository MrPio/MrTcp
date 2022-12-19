import 'package:camera/camera.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';
import 'package:mr_tcp/hardware/webcam/webcam_manger.dart';

class SendWebcam extends SendOpenHandler {
  WebcamManager? webcamManager;

  SendWebcam();

  SendWebcam.from(this.webcamManager);

  @override
  initialize(Map<String, dynamic> params) async {
    super.initialize(params);
    final cameras = await availableCameras();

    var cameraController = CameraController(
        cameras[params['camera']],
        ResolutionPreset.values
            .firstWhere((e) => e.name == params['resolution']));
    webcamManager = WebcamManager(cameraController);
  }

  @override
  open() {
    super.open();
    webcamManager!.open();
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
  stop() {
    super.stop();
    webcamManager!.close();
  }
}
