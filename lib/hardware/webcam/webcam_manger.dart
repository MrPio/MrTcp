import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../API/web_socket_manager.dart';
import '../../Utils/camera_image_conversion.dart';

class WebcamManager {
  static WebcamManager? _instance;
  WebSocketManager get  _webSocketManager=>WebSocketManager.getInstance();
  CameraController? cameraController;
  bool _isProcessing = false;
  int pkgSent = 0;

  WebcamManager._();

  static WebcamManager getInstance(){
    _instance??=WebcamManager._();
    return _instance!;
  }

  close() async{
    await cameraController!.stopImageStream();
    await cameraController!.dispose();
    cameraController = null;
  }

  open() async {
    await cameraController!.initialize();
    cameraController!.setFlashMode(FlashMode.off);

    pkgSent=0;
    cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) {
        return;
      }
      _isProcessing = true;
      var start = DateTime.now();
      var compressedImage = await convertYUV420toImageColor2(image);

      _webSocketManager.sendBytes(compressedImage);
      ++pkgSent;

      var elapsedMillis = DateTime.now().difference(start).inMilliseconds;
      if (elapsedMillis < 18) {
        await Future.delayed(Duration(milliseconds: 17 - elapsedMillis));
      }

      if (kDebugMode) {
        print('$elapsedMillis ms | package DIFF --> ${pkgSent-WebSocketManager.pingCount}');
      }
      while(pkgSent-WebSocketManager.pingCount>8){
        if (kDebugMode) {
          print('******** waiting ********');
        }
        await Future.delayed(const Duration(milliseconds: 150));
      }

      _isProcessing = false;
    });
  }
}
