// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Authoritative attributes of a player character: HP, stamina, level and XP.
///
/// Immutable value object. The **server** is the only writer — it produces a
/// new instance (via [copyWith], [addXp], ...) and assigns it to
/// [ComponentStateModel.attributes], which is what gets broadcast to the
/// clients. Level-up math lives here as a pure function so it can be
/// unit-tested without a running game server.
class PlayerAttributes {
  const PlayerAttributes({
    this.maxHp = 100,
    this.hp = 100,
    this.maxStamina = 100,
    this.stamina = 100,
    this.level = 1,
    this.xp = 0,
  });

  /// XP required to advance from one level to the next.
  static const int xpPerLevel = 100;

  final int maxHp;
  final int hp;
  final int maxStamina;
  final int stamina;
  final int level;
  final int xp;

  /// Returns a copy replacing the given fields. HP/stamina are clamped to
  /// their (possibly updated) maximums, so callers never need to clamp.
  PlayerAttributes copyWith({
    int? maxHp,
    int? hp,
    int? maxStamina,
    int? stamina,
    int? level,
    int? xp,
  }) {
    final nextMaxHp = maxHp ?? this.maxHp;
    final nextMaxStamina = maxStamina ?? this.maxStamina;
    return PlayerAttributes(
      maxHp: nextMaxHp,
      hp: _clamp(hp ?? this.hp, nextMaxHp),
      maxStamina: nextMaxStamina,
      stamina: _clamp(stamina ?? this.stamina, nextMaxStamina),
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }

  /// Adds [amount] XP and applies any level-ups.
  ///
  /// Every [xpPerLevel] XP grants one level: the XP counter resets and keeps
  /// the remainder (e.g. 250 XP at level 1 → level 3 with 50 XP).
  PlayerAttributes addXp(int amount) {
    if (amount <= 0) return this;
    var nextXp = xp + amount;
    var nextLevel = level;
    while (nextXp >= xpPerLevel) {
      nextXp -= xpPerLevel;
      nextLevel++;
    }
    if (nextLevel == level && nextXp == xp) return this;
    return copyWith(level: nextLevel, xp: nextXp);
  }

  /// Reduces HP by [damage] (clamped to 0).
  PlayerAttributes takeDamage(int damage) {
    if (damage <= 0) return this;
    return copyWith(hp: hp - damage);
  }

  /// Restores [amount] HP (clamped to [maxHp]).
  PlayerAttributes heal(int amount) {
    if (amount <= 0) return this;
    return copyWith(hp: hp + amount);
  }

  /// Adds [amount] stamina points (negative drains; clamped to [maxStamina]).
  PlayerAttributes changeStamina(int amount) {
    if (amount == 0) return this;
    return copyWith(stamina: stamina + amount);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'maxHp': maxHp,
      'hp': hp,
      'maxStamina': maxStamina,
      'stamina': stamina,
      'level': level,
      'xp': xp,
    };
  }

  factory PlayerAttributes.fromMap(Map<String, dynamic> map) {
    final nextMaxHp = _readInt(map, 'maxHp', 100);
    final nextMaxStamina = _readInt(map, 'maxStamina', 100);
    return PlayerAttributes(
      maxHp: nextMaxHp,
      hp: _clamp(_readInt(map, 'hp', nextMaxHp), nextMaxHp),
      maxStamina: nextMaxStamina,
      stamina: _clamp(
        _readInt(map, 'stamina', nextMaxStamina),
        nextMaxStamina,
      ),
      level: _readInt(map, 'level', 1),
      xp: _readInt(map, 'xp', 0),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerAttributes &&
        other.maxHp == maxHp &&
        other.hp == hp &&
        other.maxStamina == maxStamina &&
        other.stamina == stamina &&
        other.level == level &&
        other.xp == xp;
  }

  @override
  int get hashCode =>
      Object.hash(maxHp, hp, maxStamina, stamina, level, xp);

  @override
  String toString() {
    return 'PlayerAttributes(level: $level, hp: $hp/$maxHp, '
        'stamina: $stamina/$maxStamina, xp: $xp)';
  }
}

int _clamp(int value, int maxValue) {
  if (value < 0) return 0;
  if (value > maxValue) return maxValue;
  return value;
}

/// Tolerant int reader: accepts ints and numeric strings, falls back to
/// [fallback] for missing/unparsable values (mirrors `GameVector.fromMap`).
int _readInt(Map<String, dynamic> map, String key, int fallback) {
  final value = map[key];
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}
