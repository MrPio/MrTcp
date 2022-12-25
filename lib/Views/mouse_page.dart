import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../API/web_socket_manager.dart';
import '../Utils/StoreKeyValue.dart';
import 'Templates/scaffold_gradient.dart';

class MousePage extends StatefulWidget {
  final WebSocketManager webSocketManager;

  const MousePage(this.webSocketManager, {Key? key}) : super(key: key);

  @override
  State<MousePage> createState() => _MousePageState();
}

class _MousePageState extends State<MousePage> {
  bool mouseLeft = false, mouseRight = false, mouseMiddle = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                splashColor: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  if ((await StoreKeyValue.getKeys())?.contains('token') ??
                      false) {
                    await StoreKeyValue.removeData('token');
                  }
                  Navigator.popAndPushNamed(context, '/');
                },
                icon: const Icon(Icons.logout),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(widget.webSocketManager.token ?? 'Welcome',
              style: GoogleFonts.lato()),
        ),
        body: SingleChildScrollView(
          child: Stack(children: [
            Image.asset(
              'assets/mouse_skin.png',
              fit: BoxFit.fitWidth,
            ),
            mouseLeft
                ? Image.asset(
                    'assets/mouse_skin_left.png',
                    fit: BoxFit.fitWidth,
                  )
                : Container(),
            mouseRight
                ? Image.asset(
                    'assets/mouse_skin_right.png',
                    fit: BoxFit.fitWidth,
                  )
                : Container(),
            mouseMiddle
                ? Image.asset(
                    'assets/mouse_skin_middle.png',
                    fit: BoxFit.fitWidth,
                  )
                : Container(),
            Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                SizedBox(
                  height: 360,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: onLeftClicked,
                          onTapDown: (details) =>
                              setState(() => mouseLeft = true),
                          onTapUp: (details) =>
                              setState(() => mouseLeft = false),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 240,
                              child: GestureDetector(
                                onTap: onMiddleClicked,
                                onTapDown: (details) =>
                                    setState(() => mouseMiddle = true),
                                onTapUp: (details) =>
                                    setState(() => mouseMiddle = false),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: onRightClicked,
                          onTapDown: (details) =>
                              setState(() => mouseRight = true),
                          onTapUp: (details) =>
                              setState(() => mouseRight = false),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  onLeftClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_LEFT'});
  }

  onRightClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_RIGHT'});
  }

  onMiddleClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_MIDDLE'});
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    widget.webSocketManager.openStream({
      'command_name': 'GYRO_SEND',
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.webSocketManager.closeStream(
        {'type': 'command', 'command_name': 'GYRO_RECV', 'stop': 'true'});
    widget.webSocketManager.disconnect();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
