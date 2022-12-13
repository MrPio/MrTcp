import 'package:flutter/material.dart';

class ScaffoldGradient extends StatelessWidget {
  final Widget child;
  const ScaffoldGradient({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 2,
          stops: const [0.1, 0.5, 0.7, 0.9],
          colors: [
            Colors.grey[850]!,
            Colors.grey[900]!,
            Colors.grey[800]!,
            Colors.grey[700]!,
          ],
        ),
      ),
      child: child,
    );
  }
}