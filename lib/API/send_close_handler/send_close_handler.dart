import 'dart:typed_data';

abstract class SendCloseHandler{
  Map<String,dynamic> sendStart();

  Uint8List send();

  stop();
}