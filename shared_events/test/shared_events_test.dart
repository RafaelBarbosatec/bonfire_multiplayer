import 'package:shared_events/shared_events.dart';
import 'package:test/test.dart';

/// Round-trip serialization tests for the shared protocol models.
///
/// These guarantee that whatever the server serializes, the client
/// deserializes to the same value (and vice-versa) — the contract that
/// keeps client/server in sync in the multiplayer protocol.
void main() {
  group('GameVector', () {
    test('round-trip toMap/fromMap', () {
      final original = GameVector(x: 12.5, y: -3.25);
      final restored = GameVector.fromMap(original.toMap());
      expect(restored, original);
    });

    test('fromMap tolerates string values and missing keys', () {
      expect(
        GameVector.fromMap({'x': '10', 'y': '20'}),
        GameVector(x: 10, y: 20),
      );
      expect(GameVector.fromMap({}), GameVector.zero());
    });
  });

  group('ComponentStateModel', () {
    test('round-trip preserves all fields', () {
      final original = ComponentStateModel(
        id: 'player-1',
        name: 'Rafael',
        position: GameVector(x: 100.5, y: 200.25),
        size: GameVector.all(32),
        life: 80,
        speed: 120,
        direction: MoveDirectionEnum.upRight,
        lastDirection: MoveDirectionEnum.right,
        action: 'attack',
        properties: {'skin': 'boy', 'level': 3},
        lastInputId: 42,
        serverTimestamp: 123456789,
      );
      final restored = ComponentStateModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.position, original.position);
      expect(restored.size, original.size);
      expect(restored.life, original.life);
      expect(restored.speed, original.speed);
      expect(restored.direction, original.direction);
      expect(restored.lastDirection, original.lastDirection);
      expect(restored.action, original.action);
      expect(restored.properties, original.properties);
      expect(restored.lastInputId, original.lastInputId);
      expect(restored.serverTimestamp, original.serverTimestamp);
    });

    test('lastDirection falls back to direction when null', () {
      final state = ComponentStateModel(
        id: 'p',
        name: 'n',
        position: GameVector.zero(),
        size: GameVector.all(16),
        life: 100,
        direction: MoveDirectionEnum.down,
      );
      expect(state.direction, MoveDirectionEnum.down);
      expect(state.lastDirection, MoveDirectionEnum.down);
    });
  });

  group('MoveEvent', () {
    test('round-trip toMap/fromMap', () {
      final original = MoveEvent(
        position: GameVector(x: 12, y: 34),
        time: '2026-08-28T12:00:00.000Z',
        direction: MoveDirectionEnum.downLeft,
        mapId: 'map-1',
        inputId: 7,
      );
      final restored = MoveEvent.fromMap(original.toMap());
      expect(restored.position, original.position);
      expect(restored.time, original.time);
      expect(restored.direction, original.direction);
      expect(restored.mapId, original.mapId);
      expect(restored.inputId, original.inputId);
    });

    test('round-trip with null direction (idle) and null inputId', () {
      final original = MoveEvent(
        position: GameVector(x: 1, y: 2),
        time: 't',
        direction: null,
        mapId: 'map-1',
      );
      final restored = MoveEvent.fromMap(original.toMap());
      expect(restored.direction, isNull);
      expect(restored.inputId, isNull);
    });
  });

  group('GameStateModel', () {
    test('round-trip delta with players/npcs/removed', () {
      final original = GameStateModel(
        players: [
          ComponentStateModel(
            id: 'p1',
            name: 'A',
            position: GameVector(x: 1, y: 2),
            size: GameVector.all(32),
            life: 100,
          ),
        ],
        npcs: [
          ComponentStateModel(
            id: 'n1',
            name: 'B',
            position: GameVector(x: 3, y: 4),
            size: GameVector.all(16),
            life: 50,
          ),
        ],
        removed: ['old-1'],
        fullState: true,
        timestamp: 987654321,
      );
      final restored = GameStateModel.fromMap(original.toMap());
      expect(restored.players.length, 1);
      expect(restored.players.first.id, 'p1');
      expect(restored.players.first.position, GameVector(x: 1, y: 2));
      expect(restored.npcs.first.id, 'n1');
      expect(restored.removed, ['old-1']);
      expect(restored.fullState, isTrue);
      expect(restored.timestamp, 987654321);
    });
  });
}
