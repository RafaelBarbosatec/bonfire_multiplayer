import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

/// In-game status HUD (top-left), Ragnarok-inspired: character portrait,
/// level badge and HP / SP / EXP bars fed by the server-authoritative
/// [PlayerAttributes] (see shared_events).
///
/// Rendered as a Bonfire overlay so it sits above the game but stays a plain
/// Flutter widget — data comes in from [GamePage] via a `ValueListenable`.
class PlayerStatusWidget extends StatelessWidget {
  static const overlayName = 'PlayerStatusWidget';

  final PlayerAttributes attributes;
  final String name;
  final String skinPath;

  const PlayerStatusWidget({
    super.key,
    required this.attributes,
    required this.name,
    required this.skinPath,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topLeft,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: _Ro.border, width: 1.4),
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF21B2C4A), Color(0xE60D1626)],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Portrait(path: skinPath),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _Ro.ivory,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                shadows: [Shadow(color: Colors.black87)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: _Ro.border),
                              borderRadius: BorderRadius.circular(3),
                              color: const Color(0x66102030),
                            ),
                            child: Text(
                              'Lv. ${attributes.level}',
                              style: const TextStyle(
                                color: _Ro.goldBright,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _StatusBar(
                        label: 'HP',
                        value: attributes.hp,
                        maxValue: attributes.maxHp,
                        labelColor: const Color(0xFFFFB0A0),
                        gradientColors: const [
                          Color(0xFFE05545),
                          Color(0xFF8E1F1F),
                        ],
                      ),
                      const SizedBox(height: 3),
                      _StatusBar(
                        label: 'SP',
                        value: attributes.stamina,
                        maxValue: attributes.maxStamina,
                        labelColor: _Ro.gold,
                        gradientColors: const [
                          Color(0xFFEAC469),
                          Color(0xFF8A6A2F),
                        ],
                      ),
                      const SizedBox(height: 3),
                      _StatusBar(
                        label: 'EXP',
                        value: attributes.xp,
                        maxValue: PlayerAttributes.xpPerLevel,
                        labelColor: const Color(0xFF8FC1FF),
                        gradientColors: const [
                          Color(0xFF5E9ADE),
                          Color(0xFF214E79),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ragnarok-inspired palette (mirrors `_Ro` in character_select_page.dart).
class _Ro {
  static const border = Color(0xFF8A6A2F);
  static const gold = Color(0xFFE8C36A);
  static const goldBright = Color(0xFFFFE9A8);
  static const ivory = Color(0xFFF4EBD6);
}

/// Single stat bar: colored label + filled track + "value/max" readout.
class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.labelColor,
    required this.gradientColors,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color labelColor;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final pct = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return SizedBox(
      height: 12,
      width: 176,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                shadows: const [Shadow(color: Colors.black87)],
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xB3000000),
                border: Border.all(color: const Color(0xFF5A4726)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 42,
            child: Text(
              '$value/$maxValue',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _Ro.ivory,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black87)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final Map<String, Future<Sprite>> _portraitFutures = {};

/// Idle "down" frame (row 1, column 0) of a skin spritesheet, cached.
Future<Sprite> _idleSprite(String path) {
  return _portraitFutures.putIfAbsent(
    '$path|idle',
    () => Sprite.load(
      path,
      srcSize: Vector2.all(32),
      srcPosition: Vector2(0, 32),
    ),
  );
}

/// Character portrait inside a golden frame.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: _Ro.border, width: 1.2),
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFF0A1322),
      ),
      child: FutureBuilder<Sprite>(
        future: _idleSprite(path),
        builder: (context, snapshot) {
          final sprite = snapshot.data;
          if (sprite == null) {
            return const SizedBox.expand();
          }
          return CustomPaint(
            size: const Size.square(42),
            painter: _SpritePainter(sprite),
          );
        },
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite);

  final Sprite sprite;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      sprite.srcPosition.x,
      sprite.srcPosition.y,
      sprite.srcSize.x,
      sprite.srcSize.y,
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(
      sprite.image,
      src,
      dst,
      Paint()..filterQuality = ui.FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite;
}
