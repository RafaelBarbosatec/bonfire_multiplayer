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

    test('round-trip preserves attributes; absent means null', () {
      final withAttributes = ComponentStateModel(
        id: 'player-1',
        name: 'Rafael',
        position: GameVector(x: 10, y: 20),
        size: GameVector.all(32),
        life: 100,
        attributes: const PlayerAttributes(
          maxHp: 150,
          hp: 55,
          maxStamina: 80,
          stamina: 12,
          level: 3,
          xp: 30,
        ),
      );
      final restored = ComponentStateModel.fromMap(withAttributes.toMap());
      expect(restored.attributes, withAttributes.attributes);

      // NPCs (or old payloads) carry no attributes block.
      final plain = ComponentStateModel(
        id: 'npc-1',
        name: 'Slime',
        position: GameVector.zero(),
        size: GameVector.all(16),
        life: 50,
      );
      expect(ComponentStateModel.fromMap(plain.toMap()).attributes, isNull);
    });
  });

  group('PlayerAttributes', () {
    test('defaults describe a fresh level-1 Novice', () {
      const attrs = PlayerAttributes();
      expect(attrs.level, 1);
      expect(attrs.xp, 0);
      expect(attrs.hp, attrs.maxHp);
      expect(attrs.stamina, attrs.maxStamina);
      // Ragnarok: base stats start at 1, Novice has 48 status points.
      expect(attrs.str, 1);
      expect(attrs.agi, 1);
      expect(attrs.vit, 1);
      expect(attrs.intel, 1);
      expect(attrs.dex, 1);
      expect(attrs.luk, 1);
      expect(attrs.statusPoints, PlayerAttributes.initialStatusPoints);
    });

    test('round-trip toMap/fromMap', () {
      const original = PlayerAttributes(
        maxHp: 150,
        hp: 120,
        maxStamina: 80,
        stamina: 33,
        level: 7,
        xp: 42,
      );
      final restored = PlayerAttributes.fromMap(original.toMap());
      expect(restored, original);
    });

    test(
        'fromMap falls back to defaults on missing keys and tolerates '
        'numeric strings', () {
      expect(PlayerAttributes.fromMap({}), const PlayerAttributes());
      expect(
        PlayerAttributes.fromMap({
          'maxHp': '200',
          'hp': '999',
          'stamina': '-5',
          'level': '9',
          'xp': '7',
        }),
        const PlayerAttributes(
          maxHp: 200,
          hp: 200, // clamped to the new max
          maxStamina: 100,
          stamina: 0, // clamped
          level: 9,
          xp: 7,
        ),
      );
    });

    test('copyWith replaces fields and clamps hp/stamina', () {
      const base = PlayerAttributes(hp: 50, stamina: 30);
      expect(base.copyWith(hp: 500).hp, 100); // capped at maxHp
      expect(base.copyWith(hp: -10).hp, 0); // never negative
      expect(base.copyWith(stamina: 999).stamina, 100);
      expect(base.copyWith(maxHp: 300, hp: 250).hp, 250);
      expect(base.copyWith(maxStamina: 200, stamina: 150).stamina, 150);
      expect(base.copyWith(level: 4, xp: 5),
          const PlayerAttributes(level: 4, xp: 5, hp: 50, stamina: 30));
    });

    test('addXp levels up every 100 XP keeping the remainder', () {
      expect(
        const PlayerAttributes().addXp(99),
        const PlayerAttributes(level: 1, xp: 99),
      );
      // 1→2 grants floor(1/5)+3 = 3 points.
      expect(
        const PlayerAttributes().addXp(100),
        const PlayerAttributes(level: 2, xp: 0, statusPoints: 51),
      );
      // 1→2 (3 pts) + 2→3 (3 pts) = 6 points.
      expect(
        const PlayerAttributes().addXp(250),
        const PlayerAttributes(level: 3, xp: 50, statusPoints: 54),
      );
      // 5→6 grants floor(5/5)+3 = 4 points.
      expect(
        const PlayerAttributes(level: 5, xp: 90).addXp(20),
        const PlayerAttributes(level: 6, xp: 10, statusPoints: 52),
      );
      expect(const PlayerAttributes().addXp(0), const PlayerAttributes());
    });

    test('takeDamage/heal/changeStamina clamp to bounds', () {
      expect(
        const PlayerAttributes().takeDamage(30),
        const PlayerAttributes(hp: 70),
      );
      expect(
        const PlayerAttributes().takeDamage(300),
        const PlayerAttributes(hp: 0),
      );
      expect(
        const PlayerAttributes(hp: 50).heal(10),
        const PlayerAttributes(hp: 60),
      );
      expect(
        const PlayerAttributes(hp: 50).heal(999),
        const PlayerAttributes(hp: 100),
      );
      expect(
        const PlayerAttributes(stamina: 10).changeStamina(-25),
        const PlayerAttributes(stamina: 0),
      );
      expect(
        const PlayerAttributes(stamina: 90).changeStamina(25),
        const PlayerAttributes(stamina: 100),
      );
      // No-op mutations return the same logical attributes.
      expect(const PlayerAttributes().takeDamage(0), const PlayerAttributes());
      expect(const PlayerAttributes().heal(0), const PlayerAttributes());
    });

    test('stat raise cost follows the classic Ragnarok table', () {
      // ⌊(x-1)/10⌋+2 → 2 pts (1-10), 3 pts (11-20), 4 pts (21-30), ...
      expect(PlayerAttributes.costToRaiseStat(1), 2);
      expect(PlayerAttributes.costToRaiseStat(10), 2);
      expect(PlayerAttributes.costToRaiseStat(11), 3);
      expect(PlayerAttributes.costToRaiseStat(20), 3);
      expect(PlayerAttributes.costToRaiseStat(21), 4);
      expect(PlayerAttributes.costToRaiseStat(99), 11);
    });

    test('tryAllocateStat spends points, raises stat and recomputes maxima',
        () {
      // Baseline is the *derived* sheet (server normalizes on join), not the
      // raw const defaults — that is what the player actually sees.
      final base = const PlayerAttributes().withDerivedMax();
      // STR 1→2 costs 2; VIT raise must grow MaxHP (derived from VIT).
      final allocated = base.tryAllocateStat('str')!;
      expect(allocated.str, 2);
      expect(allocated.statusPoints, 46);

      final withVit = base.tryAllocateStat('vit')!;
      expect(withVit.vit, 2);
      expect(withVit.maxHp, greaterThan(base.maxHp));

      final withInt = base.tryAllocateStat('int')!;
      expect(withInt.intel, 2);
      expect(withInt.maxStamina, greaterThan(base.maxStamina));

      // INT map key is 'int' (protocol) while the field is intel.
      expect(base.statValueOrNull('int'), 1);
      expect(base.statValueOrNull('nope'), isNull);
    });

    test('tryAllocateStat rejects unaffordable, capped and invalid stats', () {
      // Not enough points for the cost (needs 2, has 1).
      expect(
        const PlayerAttributes(statusPoints: 1).tryAllocateStat('agi'),
        isNull,
      );
      // Stat already at the 99 cap.
      expect(
        const PlayerAttributes(str: 99, statusPoints: 100).tryAllocateStat(
          'str',
        ),
        isNull,
      );
      expect(const PlayerAttributes().tryAllocateStat('mystery'), isNull);
    });

    test('derived combat substats follow classic approximations', () {
      const attrs = PlayerAttributes(
        level: 10,
        str: 15,
        agi: 12,
        vit: 50,
        intel: 33,
        dex: 10,
        luk: 5,
      );
      expect(attrs.atk, 15 + 1 + 2 + 1); // STR + ⌊STR/10⌋² + DEX/5 + LUK/5
      expect(attrs.matkMin, 33 + 4 * 4); // INT + ⌊INT/7⌋² (wiki: 33 → 49)
      expect(attrs.matkMax, 33 + 6 * 6); // INT + ⌊INT/5⌋² (wiki: 33 → 69)
      expect(attrs.hit, 10 + 10);
      expect(attrs.flee, 10 + 12);
      expect(attrs.crit, 2); // ⌊5*0.3⌋ + 1
      expect(attrs.softDef, 40); // 0.8 * 50
      expect(attrs.softMdef, 33);
    });

    test('withDerivedMax recomputes pools from level + VIT/INT', () {
      final attrs = const PlayerAttributes(level: 10, vit: 20).withDerivedMax();
      expect(attrs.maxHp, ((100 + 10 * 9) * 120) ~/ 100);
      expect(attrs.maxStamina, ((100 + 5 * 9) * 101) ~/ 100);
      final clamped = const PlayerAttributes(hp: 500, vit: 1).withDerivedMax();
      expect(clamped.hp, clamped.maxHp);
    });
  });

  group('MoveEvent', () {
    test('round-trip toMap/fromMap', () {
      final original = MoveEvent(
        position: GameVector(x: 12, y: 34),
        time: 1780000000000000,
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
        time: 123456,
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
