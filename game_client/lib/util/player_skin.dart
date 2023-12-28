enum PlayerSkin {
  girl,
  boy;

  String get path {
    switch (this) {
      case PlayerSkin.girl:
        return 'player_girl.png';
      case PlayerSkin.boy:
        return 'player_boy.png';
    }
  }

  factory PlayerSkin.fromName(String name) {
    return PlayerSkin.values.firstWhere(
      (element) => element.name == name,
      orElse: () => PlayerSkin.boy,
    );
  }
}
