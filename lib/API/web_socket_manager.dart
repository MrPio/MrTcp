import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:mr_tcp/Utils/SnackbarGenerator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  static const wsUrl = 'wss://mrpio-mrpowermanager.onrender.com/ws/';
  static const packetSize = 800000;
  Function(Uint8List bytes) openHandlerCallback=(_){};

  WebSocketChannel? channel;
  bool connected=false;

  connect(BuildContext context, String token) {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl + token));
    connected=true;
    channel?.sink.add(utf8.encode('app online'));
    SnackBarGenerator.makeSnackBar(
        context, 'Connection established with token <$token>');
    channel?.stream.listen((message) {
      openHandlerCallback(message);
      // utf8.decode(message);
      // channel?.sink.add(utf8.encode('received!'));
    });
  }

  disconnect(){
    channel?.sink.close(status.goingAway);
    connected=false;
  }

  bool isConnected(){
    return connected;
  }

  sendJSON(Map<String, Object> json){
    channel?.sink.add(utf8.encode(jsonEncode(json)));
  }
  sendBytes(Uint8List bytes){
    channel!.sink.add(bytes);
  }

  Future<void> sendFile(
      PlatformFile file, Function(double)  percentageCallback) async {
    percentageCallback(0);
    final fileBytes = await File(file.path??'').readAsBytes();
    final packets = file.size ~/ packetSize + 1;
    var command = {
      'type': 'command',
      'command_type':'recv',
      'stream_type':'close',
      'command_name': 'FILE',
      'file_name': file.name,
      'file_packets': packets
    };
    sendJSON(command);
    await Future.delayed(const Duration(milliseconds: 160));
    for (var i = 0; i < packets; i++) {

      var bytes = fileBytes
              .sublist(i * packetSize, min((i + 1) * packetSize, file.size));
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

  void subscribeOpenHandler(Function(Uint8List bytes) callback) {
    openHandlerCallback=callback;
  }
  void unsubscribeOpenHandler(){
    openHandlerCallback=(_){};
  }
}
