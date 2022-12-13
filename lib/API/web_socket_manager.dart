import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:mr_tcp/Utils/SnackbarGenerator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Views/login_page.dart';

class WebSocketManager {
  static const wsUrl = 'wss://mrpio-mrpowermanager.onrender.com/ws/';
  static const packetSize = 800000;

  WebSocketChannel? channel;

  WebSocketManager(BuildContext context, String token) {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl + token));
    channel?.sink.add(utf8.encode('app online'));
    SnackBarGenerator.makeSnackBar(
        context, 'Connection established with token <$token>');
    channel?.stream.listen((message) {
      channel?.sink.add(utf8.encode('received!'));
    });
  }

  Future<void> sendFile(
      PlatformFile file, Function(double)  percentageCallback) async {
    percentageCallback(0);
    final packets = file.size ~/ packetSize + 1;
    var command = {
      'type': 'command',
      'command_name': 'FILE_SHARING',
      'file_name': file.name,
      'file_packets': packets
    };
    channel?.sink.add(utf8.encode(jsonEncode(command)));
    await Future.delayed(const Duration(milliseconds: 160));
    for (var i = 0; i < packets; i++) {
      var bytes = file.bytes
              ?.sublist(i * packetSize, min((i + 1) * packetSize, file.size)) ??
          Uint8List(0);
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
}
