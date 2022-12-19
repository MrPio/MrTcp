import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../../API/web_socket_manager.dart';
import '../../Utils/camera_image_conversion.dart';
import '../../main.dart';

class WebcamManager {
  CameraController? _cameraController;
  WebSocketManager? webSocketManager;
  bool _isProcessing = false;
  int pkgSent = 0;

  WebcamManager(this._cameraController);

  close() async{
    await _cameraController!.stopImageStream();
    await _cameraController!.dispose();
    _cameraController = null;
  }

  open() async {
    await _cameraController!.initialize();
    _cameraController!.setFlashMode(FlashMode.off);

    pkgSent=0;
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) {
        return;
      }
      _isProcessing = true;
      var start = DateTime.now();
      var compressedImage = await convertYUV420toImageColor2(image);

      MyApp.webSocketManagerInstance.sendBytes(compressedImage);
      ++pkgSent;

      var elapsedMillis = DateTime.now().difference(start).inMilliseconds;
      print('elapsed --> $elapsedMillis ms');
      if (elapsedMillis < 18) {
        await Future.delayed(Duration(milliseconds: 17 - elapsedMillis));
      }

      print('pakcage DIFF --> ${pkgSent-WebSocketManager.pingCount}');
      if(pkgSent-WebSocketManager.pingCount>16){
        print('******** ${pkgSent-WebSocketManager.pingCount>16} ********');
        await Future.delayed(const Duration(milliseconds: 200));
      }

      _isProcessing = false;
    });
  }
}
