import 'package:shared_events/shared_events.dart';
import 'package:test/test.dart';

import '../src/game/state_tracker.dart';

ComponentStateModel _player({
  PlayerAttributes? attributes,
  double x = 0,
  double y = 0,
}) {
  return ComponentStateModel(
    id: 'p1',
    name: 'A',
    position: GameVector(x: x, y: y),
    size: GameVector.all(16),
    life: 100,
    attributes: attributes,
  );
}

void main() {
  group('MapStateTracker', () {
    test('attribute-only change produces a delta (idle player)', () {
      final tracker = MapStateTracker();
      tracker.generateFullState(
        currentPlayers: [
          _player(attributes: const PlayerAttributes(stamina: 80)),
        ],
        currentNpcs: const [],
      );

      // Same position — only stamina changed (e.g. an idle regen tick).
      final delta = tracker.generateDelta(
        currentPlayers: [
          _player(attributes: const PlayerAttributes(stamina: 81)),
        ],
        currentNpcs: const [],
      );

      expect(delta.players.map((p) => p.id), ['p1']);
      expect(delta.players.first.attributes?.stamina, 81);
    });

    test('no delta when nothing changed', () {
      final tracker = MapStateTracker();
      final state = _player(attributes: const PlayerAttributes());
      tracker.generateFullState(currentPlayers: [state], currentNpcs: const []);

      final delta = tracker.generateDelta(
        currentPlayers: [state],
        currentNpcs: const [],
      );

      expect(delta.players, isEmpty);
      expect(tracker.hasChanges(delta), isFalse);
    });
  });
}
