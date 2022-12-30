import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../API/web_socket_manager.dart';
import '../Utils/StoreKeyValue.dart';
import 'Templates/laser_control.dart';
import 'Templates/mouse_control.dart';
import 'Templates/scaffold_gradient.dart';

class MousePage extends StatefulWidget {
  final WebSocketManager webSocketManager;

  const MousePage(this.webSocketManager, {Key? key}) : super(key: key);

  @override
  State<MousePage> createState() => _MousePageState();
}

class _MousePageState extends State<MousePage> {
  bool streaming = false;
  var _currentIndex = 0;
  var _pointerMode = 'GYRO';

  final screens = [
    MouseControl(),
    LaserControl(),
  ];

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
                onPressed: swapMode,
                icon: Icon(_pointerMode == 'GYRO'
                    ? Icons.open_with
                    : Icons.threesixty),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                splashColor: Theme.of(context).colorScheme.secondary,
                onPressed: logout,
                icon: const Icon(Icons.logout),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(widget.webSocketManager.token ?? 'Welcome',
              style: GoogleFonts.lato()),
        ),
        body: screens[_currentIndex],
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 76,
            height: 76,
            child: FittedBox(
              child: FloatingActionButton(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                onPressed: streaming ? stop : start,
                tooltip: streaming ? 'Stop' : 'Start',
                backgroundColor: streaming
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
                child: Icon(streaming ? Icons.stop : Icons.play_arrow),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 28,
          showUnselectedLabels: true,
          currentIndex: _currentIndex,
          onTap: (index) {
            _currentIndex = index;
            stop();
          },
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.mouse), label: 'Mouse'),
            BottomNavigationBarItem(
                icon: Icon(Icons.light_mode), label: 'Laser'),
          ],
        ),
      ),
    );
  }

  swapMode() async {
    await stop();
    _pointerMode = _pointerMode == 'GYRO' ? 'ACC' : 'GYRO';
    // start();
  }

  logout() async {
    if ((await StoreKeyValue.getKeys())?.contains('token') ?? false) {
      await StoreKeyValue.removeData('token');
    }
    Navigator.popAndPushNamed(context, '/');
  }


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  start() async {
    await widget.webSocketManager.openStream({
      'command_name': '${_pointerMode}_SEND',
      'value': _currentIndex == 0 ? 'mouse' : 'laser'
    });
    setState(() => streaming = true);
  }

  stop() async {
    await widget.webSocketManager.closeStream({
      'type': 'command',
      'command_name': '${_pointerMode}_RECV',
      'stop': 'true'
    });
    setState(() => streaming = false);
  }

  @override
  void dispose() {
    super.dispose();
    exit() async {
      await widget.webSocketManager.closeStream({
        'type': 'command',
        'command_name': '${_pointerMode}_RECV',
        'stop': 'true'
      });
      widget.webSocketManager.disconnect();
    }

    exit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
