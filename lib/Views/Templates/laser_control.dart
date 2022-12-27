import 'package:flutter/material.dart';

import '../../API/web_socket_manager.dart';

class LaserControl extends StatefulWidget {
  final WebSocketManager webSocketManager = WebSocketManager.getInstance();

  LaserControl({Key? key}) : super(key: key);

  @override
  State<LaserControl> createState() => _LaserControlState();
}

class _LaserControlState extends State<LaserControl> {
  bool laserDown = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(children: [
        Image.asset('assets/laser_pointer.png'),
        laserDown ? Image.asset('assets/laser_pointer_down.png') : Container(),
        laserDown ? Image.asset('assets/laser_pointer_strong.png') : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 305,
                ),
                SizedBox(
                  height: 140,
                  width: 140,
                  child: GestureDetector(
                    onTapDown: onLaserDown,
                    onTapUp: onLaserUp,
                    onTapCancel: onLaserCancel,
                  ),
                ),
              ],
            )
          ],
        ),
      ]),
    );
  }

  onLaserDown(_) {
    setState(()=>laserDown=true);
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'LASER_POWER','value':'strong'});
  }
  onLaserUp(_) {
    setState(()=>laserDown=false);
    widget.webSocketManager
        .sendJSON({'type': 'command', 'command_name': 'LASER_POWER','value':'normal'});

  }
  onLaserCancel() {
    setState(()=>laserDown=false);
  }
}
