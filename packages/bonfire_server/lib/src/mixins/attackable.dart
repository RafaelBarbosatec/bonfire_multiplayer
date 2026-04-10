// ignore_for_file: public_member_api_docs

import 'package:bonfire_server/src/components/positioned_game_component.dart';

mixin Attackable on PositionedGameComponent {
  double _life = 100;
  double _maxLife = 100;

  double get life => _life;
  double get maxLife => _maxLife;
  bool get isDead => _life <= 0;

  set life(double value) {
    _life = value.clamp(0, _maxLife);
  }

  void initialLife(double life) {
    _maxLife = life;
    _life = life;
  }

  void receiveDamage(double damage) {
    if (isDead) return;

    final previousLife = _life;
    _life = (_life - damage).clamp(0, _maxLife);

    if (_life != previousLife) {
      requestUpdate();
      onReceiveDamage(damage);

      if (isDead) {
        onDie();
      }
    }
  }

  void heal(double amount) {
    if (isDead) return;

    final previousLife = _life;
    _life = (_life + amount).clamp(0, _maxLife);

    if (_life != previousLife) {
      requestUpdate();
    }
  }

  void onReceiveDamage(double damage) {}

  void onDie() {}
}
