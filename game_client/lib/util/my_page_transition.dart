import 'package:flutter/material.dart';

class MyPageTransition extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return Container(
      color: Colors.black,
      child: child,
    );
  }
}
