// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Authoritative character sheet: Ragnarok-inspired base stats + runtime
/// attributes (HP/stamina/level/XP).
///
/// Immutable value object. The **server** is the only writer — it produces a
/// new instance (via [copyWith], [addXp], [tryAllocateStat], ...) and assigns
/// it to [ComponentStateModel.attributes], which is what gets broadcast to
/// the clients. All economy/derivation math lives here as pure functions so
/// it can be unit-tested without a running game server.
///
/// Rules follow classic Ragnarok (irowiki.org/classic/Stats):
/// - base stats start at 1 and cap at [statCap] (99);
/// - a normal Novice starts with [initialStatusPoints] (48) to invest;
/// - each base level grants `(level ~/ 5) + 3` status points;
/// - raising a stat from `x` to `x+1` costs `((x - 1) ~/ 10) + 2` points;
/// - investments cannot be reversed.
class PlayerAttributes {
  const PlayerAttributes({
    this.maxHp = 100,
    this.hp = 100,
    this.maxStamina = 100,
    this.stamina = 100,
    this.level = 1,
    this.xp = 0,
    this.str = 1,
    this.agi = 1,
    this.vit = 1,
    this.intel = 1,
    this.dex = 1,
    this.luk = 1,
    this.statusPoints = initialStatusPoints,
  });

  /// XP required to advance from one level to the next.
  static const int xpPerLevel = 100;

  /// Base stats a fresh character starts with.
  static const int initialStatValue = 1;

  /// Unspent status points a normal Novice starts with (classic Ragnarok).
  static const int initialStatusPoints = 48;

  /// Base stats can be raised up to 99 (bonuses may pass it later).
  static const int statCap = 99;

  /// Protocol keys of the six primary stats, in classic display order.
  static const List<String> statKeys = [
    'str',
    'agi',
    'vit',
    'int',
    'dex',
    'luk',
  ];

  final int maxHp;
  final int hp;
  final int maxStamina;
  final int stamina;
  final int level;
  final int xp;

  // Base stats (classic Ragnarok). `intel` keeps the Dart keyword clear; the
  // protocol/map key is 'int' (INT).
  final int str;
  final int agi;
  final int vit;
  final int intel;
  final int dex;
  final int luk;

  /// Unspent status points available to raise base stats.
  final int statusPoints;

  // --- Derived max pools (classic-inspired approximations for v1) ---------

  /// MaxHP grows with level and +1% per VIT (VIT section, irowiki).
  int get derivedMaxHp => ((100 + 10 * (level - 1)) * (100 + vit)) ~/ 100;

  /// Max stamina/SP grows with level and +1% per INT.
  int get derivedMaxStamina => ((30 + 3 * (level - 1)) * (100 + intel)) ~/ 100;

  // --- Derived combat substats (classic-inspired, v1 display) -------------

  /// Melee ATK: STR scales 1:1 plus the STR/10 square bonus; DEX/LUK add 1
  /// every 5 points (classic bonus tables).
  int get atk => str + (str ~/ 10) * (str ~/ 10) + dex ~/ 5 + luk ~/ 5;

  /// MATK minimum = INT + ⌊INT/7⌋² (classic INT chart).
  int get matkMin => intel + (intel ~/ 7) * (intel ~/ 7);

  /// MATK maximum = INT + ⌊INT/5⌋² (classic INT chart).
  int get matkMax => intel + (intel ~/ 5) * (intel ~/ 5);

  /// HIT = DEX + base level (classic substats).
  int get hit => level + dex;

  /// FLEE = AGI + base level (classic substats).
  int get flee => level + agi;

  /// Status-window CRIT ≈ LUK*0.3 + 1 (classic).
  int get crit => (luk * 3) ~/ 10 + 1;

  /// VIT-based soft DEF ≈ 0.8 per VIT (classic).
  int get softDef => (vit * 8) ~/ 10;

  /// INT-based soft MDEF ≈ +1 per INT (classic).
  int get softMdef => intel;

  // --- Stat economy (classic Ragnarok) ------------------------------------

  /// Cost (in status points) to raise a stat from [current] to current + 1:
  /// `⌊(current - 1) / 10⌋ + 2` (1-10 → 2, 11-20 → 3, 21-30 → 4, ...).
  static int costToRaiseStat(int current) => (current - 1) ~/ 10 + 2;

  /// Value of the base stat identified by [key] (one of [statKeys]), or null
  /// for unknown keys.
  int? statValueOrNull(String key) {
    return switch (key) {
      'str' => str,
      'agi' => agi,
      'vit' => vit,
      'int' => intel,
      'dex' => dex,
      'luk' => luk,
      _ => null,
    };
  }

  /// Attempts to invest one point in [key] (classic rules: no refunds, cap 99,
  /// progressive cost). Returns a new instance with the stat raised, points
  /// spent and derived maxima recomputed — or null when invalid/not affordable.
  PlayerAttributes? tryAllocateStat(String key) {
    final current = statValueOrNull(key);
    if (current == null || current >= statCap) return null;
    final cost = costToRaiseStat(current);
    if (statusPoints < cost) return null;
    return _copyWithStat(key, current + 1, statusPoints - cost)
        .withDerivedMax();
  }

  /// Recomputes [maxHp]/[maxStamina] from the current level + VIT/INT and
  /// clamps hp/stamina to the new pools (e.g. after a level-up or stat
  /// investment changed the maxima).
  PlayerAttributes withDerivedMax() {
    return copyWith(
      maxHp: derivedMaxHp,
      maxStamina: derivedMaxStamina,
    );
  }

  PlayerAttributes _copyWithStat(String key, int value, int points) {
    return switch (key) {
      'str' => copyWith(str: value, statusPoints: points),
      'agi' => copyWith(agi: value, statusPoints: points),
      'vit' => copyWith(vit: value, statusPoints: points),
      'int' => copyWith(intel: value, statusPoints: points),
      'dex' => copyWith(dex: value, statusPoints: points),
      'luk' => copyWith(luk: value, statusPoints: points),
      _ => this,
    };
  }

  // --- Mutations ----------------------------------------------------------

  /// Returns a copy replacing the given fields. HP/stamina are clamped to
  /// their (possibly updated) maximums, so callers never need to clamp.
  PlayerAttributes copyWith({
    int? maxHp,
    int? hp,
    int? maxStamina,
    int? stamina,
    int? level,
    int? xp,
    int? str,
    int? agi,
    int? vit,
    int? intel,
    int? dex,
    int? luk,
    int? statusPoints,
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
      str: str ?? this.str,
      agi: agi ?? this.agi,
      vit: vit ?? this.vit,
      intel: intel ?? this.intel,
      dex: dex ?? this.dex,
      luk: luk ?? this.luk,
      statusPoints: statusPoints ?? this.statusPoints,
    );
  }

  /// Adds [amount] XP and applies any level-ups.
  ///
  /// Every [xpPerLevel] XP grants one level: the XP counter resets and keeps
  /// the remainder (e.g. 250 XP at level 1 → level 3 with 50 XP). Each level
  /// gained from `L` to `L+1` grants `(L ~/ 5) + 3` status points (classic).
  PlayerAttributes addXp(int amount) {
    if (amount <= 0) return this;
    var nextXp = xp + amount;
    var nextLevel = level;
    var nextPoints = statusPoints;
    while (nextXp >= xpPerLevel) {
      nextXp -= xpPerLevel;
      nextPoints += (nextLevel ~/ 5) + 3;
      nextLevel++;
    }
    if (nextLevel == level && nextXp == xp) return this;
    return copyWith(level: nextLevel, xp: nextXp, statusPoints: nextPoints);
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

  // --- Serialization ------------------------------------------------------

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'maxHp': maxHp,
      'hp': hp,
      'maxStamina': maxStamina,
      'stamina': stamina,
      'level': level,
      'xp': xp,
      'str': str,
      'agi': agi,
      'vit': vit,
      'int': intel,
      'dex': dex,
      'luk': luk,
      'statusPoints': statusPoints,
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
      str: _readInt(map, 'str', initialStatValue),
      agi: _readInt(map, 'agi', initialStatValue),
      vit: _readInt(map, 'vit', initialStatValue),
      intel: _readInt(map, 'int', initialStatValue),
      dex: _readInt(map, 'dex', initialStatValue),
      luk: _readInt(map, 'luk', initialStatValue),
      statusPoints: _readInt(map, 'statusPoints', initialStatusPoints),
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
        other.xp == xp &&
        other.str == str &&
        other.agi == agi &&
        other.vit == vit &&
        other.intel == intel &&
        other.dex == dex &&
        other.luk == luk &&
        other.statusPoints == statusPoints;
  }

  @override
  int get hashCode => Object.hash(maxHp, hp, maxStamina, stamina, level, xp,
      str, agi, vit, intel, dex, luk, statusPoints);

  @override
  String toString() {
    return 'PlayerAttributes(level: $level, xp: $xp, hp: $hp/$maxHp, '
        'sp: $stamina/$maxStamina, STR $str/AGI $agi/VIT $vit/'
        'INT $intel/DEX $dex/LUK $luk, points: $statusPoints)';
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
