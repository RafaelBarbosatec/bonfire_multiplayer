// ignore_for_file: public_member_api_docs

import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/mixins/use_state.dart';

mixin Attackable on PositionedGameComponent {
  int _life = 100;
  int _maxLife = 100;

  int get life => _life;
  int get maxLife => _maxLife;
  bool get isDead => _life <= 0;

  set life(int value) {
    final newLife = value.clamp(0, _maxLife);
    if (_life != newLife) {
      _life = newLife;
      _updateStateLife();
    }
  }

  void initialLife(int life) {
    _maxLife = life;
    _life = life;
    _updateStateLife();
  }

  void receiveDamage(int damage) {
    if (isDead) return;

    final previousLife = _life;
    _life = (_life - damage).clamp(0, _maxLife);

    if (_life != previousLife) {
      _updateStateLife();
      requestUpdate();
      onReceiveDamage(damage);

      if (isDead) {
        onDie();
      }
    }
  }

  void heal(int amount) {
    if (isDead) return;

    final previousLife = _life;
    _life = (_life + amount).clamp(0, _maxLife);

    if (_life != previousLife) {
      _updateStateLife();
      requestUpdate();
    }
  }

  void _updateStateLife() {
    if (this is UseState) {
      (this as UseState).state.life = _life;
    }
  }

  void onReceiveDamage(int damage) {}

  void onDie() {}
}
