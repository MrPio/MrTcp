import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ScaffoldGradient extends StatelessWidget {
  final Widget child;
  const ScaffoldGradient({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool dark = brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
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
      ),
      child: child,
    );
  }
}