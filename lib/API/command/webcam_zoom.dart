import 'package:mr_tcp/API/command/command.dart';
import 'package:mr_tcp/hardware/webcam/webcam_manger.dart';

class WebcamZoom extends Command {
  WebcamManager get _webcamManager => WebcamManager.getInstance();

  @override
  execute(Map<String, dynamic> cmd) async {
    super.execute(cmd);
    var cam = _webcamManager.cameraController;
    if (cam == null) {
      return;
    }
    var value = cmd['value'];
    var min = await cam.getMinZoomLevel();
    var max = await cam.getMaxZoomLevel();
    await cam.setZoomLevel(min + (max - min) * value);
  }
}
