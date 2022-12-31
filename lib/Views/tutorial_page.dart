import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_walkthrough_screen/flutter_walkthrough_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_tcp/API/web_socket_manager.dart';
import 'package:mr_tcp/Views/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/StoreKeyValue.dart';

class TutorialPage extends StatefulWidget {
  TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {


  @override
  Widget build(BuildContext context) {
    final List<OnbordingData> list = [
      OnbordingData(
        image: AssetImage("assets/mouse_skin_half.png"),
        descPadding: EdgeInsets.symmetric(horizontal: 22.0),
        fit: BoxFit.cover,

        imageWidth: MediaQuery.of(context).size.width*0.9,
        titleText: Text("Welcome to MrPointer!",
            style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 22)),
        descText: Text(
            textAlign: TextAlign.center,
            "Use this app to transform your phone in a pointer ad use it as mouse on your pc!",
            style: GoogleFonts.lato(fontWeight: FontWeight.w300, fontSize: 20)),
      ),
      OnbordingData(
        image: AssetImage("assets/pc002.png"),
        fit: BoxFit.cover,
        imageHeight: MediaQuery.of(context).size.width*0.9*.52,
        imageWidth: MediaQuery.of(context).size.width*0.9,

        descPadding: EdgeInsets.symmetric(horizontal: 22.0),
        titleText: Text("Download the software on your pc.",
            style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 22)),
        descText: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: "Go to this link: ",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w300, fontSize: 20,color: Theme.of(context).colorScheme.onSecondary)),
              TextSpan(
                text: 'https://github.com/MrPio/MrPointer',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900, fontSize: 20,color: Theme.of(context).colorScheme.onSecondary),
                recognizer: TapGestureRecognizer()..onTap = () {
                    launchUrl(Uri.parse('https://github.com/MrPio/MrPointer'));
                  },
              ),
              TextSpan(
                  text:
                  " download the software on your pc and run it. You will use it to establish the connection with your phone!",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w300, fontSize: 20,color: Theme.of(context).colorScheme.onSecondary)),
            ],
          ),
        ),
      ),
      OnbordingData(
        image: AssetImage("assets/pc001.png"),
        fit: BoxFit.cover,
        imageHeight: MediaQuery.of(context).size.width*0.9*.674,
        imageWidth: MediaQuery.of(context).size.width*0.9,
        descPadding: EdgeInsets.symmetric(horizontal: 22.0),
        titleText: Text("Choose a token",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 22)),
        descText: Text(
            textAlign: TextAlign.center,
            "Use it to connect this app with the software you downloaded earlier.",
            style: GoogleFonts.lato(fontWeight: FontWeight.w300, fontSize: 20)),
      ),
      OnbordingData(
        image: AssetImage("assets/star.png"),
        imageHeight: MediaQuery.of(context).size.width*0.5,
        imageWidth: MediaQuery.of(context).size.width*0.5,
        descPadding: EdgeInsets.symmetric(horizontal: 22.0),
        titleText: Text("Good job!",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 22)),
        descText: Text("Everything is now ready!",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontWeight: FontWeight.w300, fontSize: 20)),
      ),
    ];
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool dark = brightness == Brightness.dark;
    /* remove the back button in the AppBar is to set automaticallyImplyLeading to false
  here we need to pass the list and the route for the next page to be opened after this. */
    return IntroScreen(
      onbordingDataList: list,
      gradient: RadialGradient(
        radius: 2,
        stops: const [0.1, 0.5, 0.7, 0.9],
        colors: [
          dark?Colors.grey[850]!:Colors.tealAccent[100]!,
          dark?Colors.grey[900]!:Colors.teal[500]!,
          dark?Colors.grey[800]!:Colors.teal!,
          dark?Colors.grey[900]!:Colors.teal!,
        ],
      ),
      colors: const [
        Colors.black,Colors.black,Colors.black,Colors.black,Colors.black
      ],
      pageRoute: MaterialPageRoute(
        builder: (context) => LoginPage(WebSocketManager.getInstance()),
      ),
      nextButton:  Text(
        "NEXT",
        style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 18,color: Theme.of(context).colorScheme.onSecondary),
      ),
      lastButton:  Text(
        "GOT IT",
        style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 18,color: Theme.of(context).colorScheme.onSecondary),
      ),
      skipButton: Text(
        "SKIP",
        style: GoogleFonts.lato(fontWeight: FontWeight.w400, fontSize: 18,color: Theme.of(context).colorScheme.onSecondary),
      ),
      selectedDotColor: Colors.tealAccent,
      unSelectdDotColor: Colors.grey,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if ((await StoreKeyValue.getKeys())?.contains('tutorial') ?? false) {
        Navigator.popAndPushNamed(context, '/login');
      }
    });
  }
}
