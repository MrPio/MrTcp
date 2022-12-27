import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/web_socket_manager.dart';

class WebcamStreaming extends StatefulWidget {
  final WebSocketManager webSocketManager;

  const WebcamStreaming(this.webSocketManager, {Key? key}) : super(key: key);

  @override
  WebcamStreamingState createState() => WebcamStreamingState();
}

class WebcamStreamingState extends State<WebcamStreaming> {
  Image? frame;
  Image? oldFrame;
  Image? veryOldFrame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: frame == null
          ? Container()
          : Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(0),
                  minScale: 0.8,
                  maxScale: 4,
                  onInteractionStart: (details) {
                    // hideHand=true;
                  },
                  child: GestureDetector(
                    onDoubleTap: () {},
                    child: Stack(
                      children: [
                        veryOldFrame!,
                        oldFrame!,
                        frame!,
                      ],
                    )
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
/*    callback(Uint8List bytes){
      setState(() {veryOldFrame=oldFrame;});
      setState(() {oldFrame=frame;});
      frame=Image.memory(bytes);
      setState(() {});
    }
    widget.webSocketManager.subscribeOpenHandler(callback);*/
  }

  @override
  void dispose() {
    // widget.webSocketManager.unsubscribeOpenHandler();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}
