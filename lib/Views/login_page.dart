import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_tcp/Utils/SnackbarGenerator.dart';
import 'package:mr_tcp/Utils/size_adjustaments.dart';
import 'package:mr_tcp/Views/Templates/scaffold_gradient.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../API/web_socket_manager.dart';

class LoginPage extends StatefulWidget {
  static WebSocketManager? webSocketManager;

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Color? floatingSignupColor = Colors.grey[700];
  TextEditingController tokenInput = TextEditingController();
  double percentage=0.0;
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (LoginPage.webSocketManager==null){
                    SnackBarGenerator.makeSnackBar(context, 'First you need to establish a connection!',color: Colors.red);
                    return;
                  }
                  var file = (await FilePicker.platform.pickFiles())?.files[0];
                  if (file == null) {
                    return;
                  }
                  await LoginPage.webSocketManager?.sendFile(file,percentageCallback);
                },
                child: const Text('Send file'),
              ),
              const SizedBox(height: 50),
              LinearProgressIndicator(
                value: percentage,
              ),
              const SizedBox(height: 20),
              Text('${(percentage*100).toStringAsFixed(2)} %',style: GoogleFonts.lato(fontSize: 22),)
            ],
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
                  backgroundColor: LoginPage.webSocketManager==null?
                  Colors.tealAccent:Colors.redAccent,
                  child: Icon( LoginPage.webSocketManager==null?
                  Icons.laptop_chromebook:Icons.close),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void floatingActionButtonAction() {
    if (LoginPage.webSocketManager!=null){
      LoginPage.webSocketManager?.channel?.sink.close(status.goingAway);
      LoginPage.webSocketManager=null;
      percentage=0;
      setState(() {});
      SnackBarGenerator.makeSnackBar(context, 'Connection closed');
      return;
    }
    if (tokenInput.text.length < 3) {
      SnackBarGenerator.makeSnackBar(
          context, "Token must be at least 3 chars long!",
          color: Colors.red);
      return;
    }
    LoginPage.webSocketManager = WebSocketManager(context,tokenInput.text);
    setState(() {});
  }
}
