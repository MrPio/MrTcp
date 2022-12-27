import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:mr_tcp/API/web_socket_manager.dart';

class MouseControl extends StatefulWidget {
  final WebSocketManager webSocketManager=WebSocketManager.getInstance();
  MouseControl({Key? key}) : super(key: key);

  @override
  State<MouseControl> createState() => _MouseControlState();
}

class _MouseControlState extends State<MouseControl> {
  bool mouseLeft = false, mouseRight = false, mouseMiddle = false;
  final audioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      onTapDown: onLeftDown,
                      onTapUp: onLeftUp,
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
                            onTapDown: onMiddleDown,
                            onTapUp: onMiddleUp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: onRightClicked,
                      onTapDown: onRightDown,
                      onTapUp: onRightUp,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }


  onLeftDown(_) {
    setState(() => mouseLeft = true);
    audioPlayer.open(Audio("assets/click_down.mp3"));
  }

  onLeftUp(_) {
    setState(() => mouseLeft = false);
    audioPlayer.open(Audio("assets/click_up.mp3"));
  }

  onLeftClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_LEFT'});
  }

  onRightDown(_) {
    setState(() => mouseRight = true);
    audioPlayer.open(Audio("assets/click_down.mp3"));
  }

  onRightUp(_) {
    setState(() => mouseRight = false);
    audioPlayer.open(Audio("assets/click_up.mp3"));
  }

  onRightClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_RIGHT'});
  }

  onMiddleDown(_) {
    setState(() => mouseMiddle = true);
  }

  onMiddleUp(_) {
    setState(() => mouseMiddle = false);
  }

  onMiddleClicked() {
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'MOUSE_MIDDLE'});
  }

}
