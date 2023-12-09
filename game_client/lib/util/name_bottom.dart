import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

mixin WithNameBottom on GameComponent {
  String name = '';
  @override
  Future<void> onLoad() {
    // Adds name text
    final textRender = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: width / 4,
      ),
    );
    final metrics = textRender.getLineMetrics(name);
    final x = (width - metrics.width) / 2;
    add(
      TextComponent(
        text: name,
        position: Vector2(x, height),
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.black,
            fontSize: width / 4,
          ),
        ),
      ),
    );
    return super.onLoad().asFuture();
  }
}
