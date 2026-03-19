class GameTimer {
  GameTimer({
    required this.duration,
    this.loop = false,
    this.onFinish,
  });
  final void Function()? onFinish;
  final double duration;
  final bool loop;
  bool _finished = false;
  double _elapsedTime = 0;

  bool update(double dt) {
    _elapsedTime += dt;
    if (_elapsedTime >= duration && !_finished) {
      _finished = true;
      onFinish?.call();
      if (loop) {
        reset();
      }
      return true;
    }
    return false;
  }

  double get elapsedTime => _elapsedTime;

  void reset() {
    _elapsedTime = 0.0;
    _finished = false;
  }
}
