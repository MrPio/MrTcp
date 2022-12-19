import 'package:flutter/material.dart';
import 'package:mr_tcp/Views/login_page.dart';
import 'package:mr_tcp/Views/webcam_streaming.dart';

import 'API/web_socket_manager.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static WebSocketManager webSocketManagerInstance=WebSocketManager();
  final webSocketManager=webSocketManagerInstance;
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MrTcp by MrPio',
      theme: ThemeData.dark(),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => LoginPage(webSocketManager),
        '/webcam_streaming':(BuildContext context)=>WebcamStreaming(webSocketManager)
      },
    );
  }
}
