import 'package:camera/camera.dart';
import 'package:mr_tcp/API/command/command.dart';
import '../../hardware/webcam/webcam_manger.dart';

class WebcamFlash extends Command {
  WebcamManager get _webcamManager => WebcamManager.getInstance();

  @override
  execute(Map<String, dynamic> cmd) async {
    super.execute(cmd);
    var cam = _webcamManager.cameraController;
    if (cam == null) {
      return;
    }
    cam.setFlashMode(cmd['value']=='on'?FlashMode.torch: FlashMode.off);
  }
}
