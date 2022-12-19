import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:mr_tcp/API/recv_close_handler/recv_close_handler.dart';
import 'package:mr_tcp/API/recv_open_handler/recv_open_handler.dart';
import 'package:mr_tcp/API/send_close_handler/send_close_handler.dart';
import 'package:mr_tcp/API/send_open_handler/send_open_handler.dart';
import 'package:mr_tcp/API/send_open_handler/send_webcam.dart';
import 'package:mr_tcp/Utils/SnackbarGenerator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  static const wsUrl = 'wss://mrpio-mrpowermanager.onrender.com/ws/';
  static const packetSize = 800000;
  Function(Uint8List bytes) openHandlerCallback = (_) {};

  WebSocketChannel? channel;
  bool connected = false;
  static int pingCount = 0;
  Map<String, dynamic>? currentCommand, lastJson;

  //HANDLERS
  Map<String, RecvCloseHandler> recvCloseHandlers = {
    // 'FILE_RECV': RecvFile(),
  };

  Map<String, RecvOpenHandler> recvOpenHandlers = {
    // 'WEBCAM_RECV': RecvWebcam(),TODO
  };

  Map<String, SendCloseHandler> sendCloseHandlers = {};

  Map<String, SendOpenHandler> sendOpenHandlers = {
    'WEBCAM_SEND': SendWebcam(),
  };

  connect(BuildContext context, String token) {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl + token));
    connected = true;
    channel?.sink.add(utf8.encode('app online'));
    SnackBarGenerator.makeSnackBar(
        context, 'Connection established with token <$token>');
    channel?.stream.listen((message) {
      onMessage(message);
    });
  }

  processJson(Map<String, dynamic> json) {
    lastJson = json;
    if (json['type'] == 'command') {
      currentCommand = json;

      //initialize the handler if it is a "send/open" one
      if (sendOpenHandlers.containsKey(json['command_name'])) {
        if (json.containsKey('stop')) {
          closeStream(json);
        } else {
          openStream(json);
        }
      }
    }
  }

  openStream(Map<String, dynamic> cmd) async {
    var cmdName = cmd['command_name'];
    var handler = sendOpenHandlers[cmdName];
    await handler!.initialize(cmd);
    sendJSON(handler.sendStart());
    handler.open();
  }

  closeStream(Map<String, dynamic> cmd) async {
    await sendOpenHandlers[cmd['command_name']]?.stop();
    //lo rimando perchè non so se è il telefono che ha stoppato oppure il pc che lo ha richiesto
    //nel primo caso, devo comunicare lo stop al pc
    sendJSON(cmd);
  }

  processString(String str) {
    if (str=='PKG_RECV'){
      pingCount+=1;
    }
    print('recived --> $str');
    //TODO SNACKBAR WITH CALLBACK
  }

  processBytes(Uint8List bytes) {
    if (currentCommand == null) {
      return;
    }
    var cmd = currentCommand!['command_name'];
    if (recvCloseHandlers.containsKey(cmd)) {
      recvCloseHandlers[cmd]!.process(bytes, lastJson!['md5']);
    } else if (recvOpenHandlers.containsKey(cmd)) {
      recvOpenHandlers[cmd]!.process(bytes);
    }
    // openHandlerCallback(bytes);
  }

  onMessage(Uint8List bytes) {
    try {
      var str = utf8.decode(bytes.toList());
      try {
        //is Json
        processJson(convert.jsonDecode(str));
        return;
      } catch (e) {
        // print(e);
      }
      //is string
      processString(str);
      return;
    } catch (e) {
      // print(e);
    }
    //is bytes
    processBytes(bytes);
  }

  disconnect() {
    channel?.sink.close(status.goingAway);
    connected = false;
  }

  bool isConnected() {
    return connected;
  }

  sendJSON(Map<String, dynamic> json) {
    channel?.sink.add(utf8.encode(jsonEncode(json)));
  }

  sendBytes(Uint8List bytes) {
    channel!.sink.add(bytes);
  }

  Future<void> sendFile(
      PlatformFile file, Function(double) percentageCallback) async {
    percentageCallback(0);
    final fileBytes = await File(file.path ?? '').readAsBytes();
    final packets = file.size ~/ packetSize + 1;
    var command = {
      'type': 'command',
      'command_type': 'recv',
      'stream_type': 'close',
      'command_name': 'FILE',
      'file_name': file.name,
      'file_packets': packets
    };
    sendJSON(command);
    await Future.delayed(const Duration(milliseconds: 160));
    for (var i = 0; i < packets; i++) {
      var bytes = fileBytes.sublist(
          i * packetSize, min((i + 1) * packetSize, file.size));
      var command = {'type': 'checksum', 'md5': checksum(bytes)};
      channel?.sink.add(utf8.encode(jsonEncode(command)));
      channel?.sink.add(bytes);
      await Future.delayed(const Duration(milliseconds: 100));
      percentageCallback((i + 1) / packets);
      print('passo--->$i');
    }
  }

  String checksum(Uint8List content) {
    return md5.convert(utf8.encode(base64.encode(content))).toString();
  }
/*
  void subscribeOpenHandler(Function(Uint8List bytes) callback) {
    openHandlerCallback = callback;
  }

  void unsubscribeOpenHandler() {
    openHandlerCallback = (_) {};
  }*/
}
