import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mr_tcp/Views/login_page.dart';
import 'package:mr_tcp/Views/webcam_streaming_page.dart';

import 'API/web_socket_manager.dart';
import 'Views/mouse_page.dart';
import 'Views/tutorial_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  WebSocketManager get webSocketManager => WebSocketManager.getInstance();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool dark = brightness == Brightness.dark;
    return MaterialApp(
      theme: ThemeData(
          brightness: brightness,
          splashFactory: InkRipple.splashFactory,
          // primaryColorLight: Colors.yellow,
          // primaryColorDark: Colors.teal,
          // primaryColor: Colors.yellow,
          // focusColor: dark ? Colors.teal : Colors.tealAccent,
          splashColor: Colors.white.withAlpha(1001  ),
          colorScheme: ColorScheme(
              brightness: brightness,
              primary: dark ? Colors.tealAccent[400]! : Colors.teal[600]!,
              onPrimary: Colors.black87,
              secondary: dark ? Colors.tealAccent[700]! : Colors.tealAccent,
              onSecondary: dark ? Colors.white : Colors.black87,
              error: Colors.red,
              onError: Colors.black54,
              background: Colors.black54,
              onBackground: Colors.tealAccent,
              surface: Colors.black26,
              onSurface: dark ? Colors.white : Colors.teal[800]!,
          )
      ),
      title: 'MrTcp by MrPio',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(webSocketManager),
        '/': (BuildContext context) => TutorialPage(),
        '/mouse_page': (BuildContext context) => MousePage(webSocketManager),
        '/webcam_streaming': (BuildContext context) =>
            WebcamStreaming(webSocketManager)
      },
    );
  }
}
