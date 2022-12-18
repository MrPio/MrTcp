import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_tcp/Utils/SnackbarGenerator.dart';
import 'package:mr_tcp/Views/Templates/scaffold_gradient.dart';
import 'package:mr_tcp/Views/webcam_streaming.dart';

import '../API/web_socket_manager.dart';
import '../Utils/camera_image_conversion.dart';
import '../Utils/input_dialog.dart';
import 'Templates/dialog_single_choice.dart';

class LoginPage extends StatefulWidget {
  final WebSocketManager webSocketManager;

  const LoginPage(this.webSocketManager, {super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Color? floatingSignupColor = Colors.grey[700];
  TextEditingController tokenInput = TextEditingController();
  double percentage = 0.0;

  percentageCallback(newPercentage) {
    setState(() {
      percentage = newPercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text("Login page", style: GoogleFonts.lato()),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Gimme the token to connect to:",
                  style: GoogleFonts.lato(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: tokenInput,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        hintText: 'token',
                        icon: Icon(Icons.connected_tv, size: 36)),
                    style: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (!widget.webSocketManager.isConnected()) {
                      SnackBarGenerator.makeSnackBar(
                          context, 'First you need to establish a connection!',
                          color: Colors.red);
                      return;
                    }
                    var file =
                        (await FilePicker.platform.pickFiles())?.files[0];
                    if (file == null) {
                      return;
                    }
                    await widget.webSocketManager
                        .sendFile(file, percentageCallback);
                  },
                  child: const Text('Send file'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/webcam_streaming'),
                    child: const Text('Webcam stream RECV')),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async {
                      final cameras = await availableCameras();
                      var choice = 0;
                      var names = cameras.map((e) => e.name).toList();
                      if (cameras.length > 1) {
                        choice = await showSingleChoiceDialog(
                            context, 'Select the webcam', names);
                        if (choice == -1) {
                          return;
                        }
                      }
                      final selected_camera = cameras[choice];
                      var _controller = CameraController(
                        selected_camera,
                        ResolutionPreset.low,
                        enableAudio: false,
                      );

                      var command = {
                        'type': 'command',
                        'command_type': 'recv',
                        'stream_type': 'open',
                        'command_name': 'WEBCAM',
                      };
                      widget.webSocketManager.sendJSON(command);
/*
                      await _controller.initialize();

                      _controller.startImageStream((CameraImage image) async{
                        var start = DateTime.now();
                        var compressedImage =convertYUV420toImageColorWithC(image);

                        widget.webSocketManager.sendBytes(compressedImage);

                        print(compressedImage.length);
                        print((DateTime.now()
                            .difference(start)
                            .inMilliseconds));

                        await Future.delayed(const Duration(milliseconds: 1000));
                        // sleep(const Duration(milliseconds: 1000));

                        // print(compressedImage!.length);
                        // _controller.stopImageStream();
                      });
*/

                      await _controller.initialize();

                      _controller.setFlashMode(FlashMode.off);
                      // _controller.setFocusMode(FocusMode.locked);
                      widget.webSocketManager.sendJSON(command);
                      while (true){
                        var start=DateTime.now();
                        final image = await _controller.takePicture();
                        var bytes=await compressImage(File(image.path));
                        widget.webSocketManager.sendBytes(bytes!);
                        File(image.path).delete();
                        print((DateTime.now().difference(start).inMilliseconds));
                      }
                    },
                    child: const Text('Webcam stream SEND')),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async {
                      var msg = await inputDialog(context, 'Gimme your message',
                          'hello', Icons.message);
                      widget.webSocketManager
                          .sendBytes(Uint8List.fromList(utf8.encode(msg)));
                    },
                    child: const Text('Send Message')),
                const SizedBox(height: 50),
                LinearProgressIndicator(
                  value: percentage,
                ),
                const SizedBox(height: 20),
                Text(
                  '${(percentage * 100).toStringAsFixed(2)} %',
                  style: GoogleFonts.lato(fontSize: 22),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.yellow),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 68,
              height: 68,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: floatingActionButtonAction,
                  tooltip: 'Connect',
                  backgroundColor: !widget.webSocketManager.isConnected()
                      ? Colors.tealAccent
                      : Colors.redAccent,
                  child: Icon(!widget.webSocketManager.isConnected()
                      ? Icons.laptop_chromebook
                      : Icons.close),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void floatingActionButtonAction() {
    if (widget.webSocketManager.isConnected()) {
      widget.webSocketManager.disconnect();
      percentage = 0;
      setState(() {});
      SnackBarGenerator.makeSnackBar(context, 'Connection closed');
      return;
    }
/*    if (tokenInput.text.length < 3) {
      SnackBarGenerator.makeSnackBar(
          context, "Token must be at least 3 chars long!",
          color: Colors.red);
      return;
    }*/
    widget.webSocketManager.connect(context, 'mrpio1'/*tokenInput.text*/);
    setState(() {});
  }
}
