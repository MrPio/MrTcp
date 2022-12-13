import 'package:flutter/material.dart';

double adjH(BuildContext context, double value) {
  return value * MediaQuery.of(context).size.width / 411.4;
}
double adjV(BuildContext context, double value) {
  return value * MediaQuery.of(context).size.height / 683.4;
}
