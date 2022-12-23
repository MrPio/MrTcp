import 'dart:typed_data';

import 'package:mr_tcp/API/web_socket_manager.dart';

abstract class SendOpenHandler{
  bool isOpen=false;

  initialize(Map<String,dynamic> params){
    WebSocketManager.pingCount=0;
  }

  Map<String,dynamic> sendStart();

  open(){
    isOpen=true;
  }

  stop()async{
    isOpen=false;
  }
}