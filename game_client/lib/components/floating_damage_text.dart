import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Short-lived world-space damage number: floats up from the hit position and
/// disappears. Added directly to the game root (world coordinates).
class FloatingDamageText extends TextComponent {
  FloatingDamageText({required Vector2 at, required int damage})
    : super(
        text: '-$damage',
        position: at,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFE9A8),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
          ),
        ),
      );

  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    position.y -= 16 * dt;
    if (_age > 0.65) {
      removeFromParent();
    }
    super.update(dt);
  }
}
