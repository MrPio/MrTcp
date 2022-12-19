import 'dart:typed_data';

abstract class RecvCloseHandler{
  int pkgRecv=0,pkgTot=0;
  DateTime? sharingStart;

  initialize(){
    pkgRecv=0;
    pkgTot=0;
    sharingStart=DateTime.now();
  }

  process(Uint8List msg,String checksum);

  stop();
}