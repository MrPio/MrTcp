import 'dart:typed_data';

abstract class RecvOpenHandler{
  process(Uint8List msg);

  stop();
}