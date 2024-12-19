import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

abstract class Timeline<T> {}

class Empty<T> extends Timeline<T> {}

class Delay<T> extends Timeline<T> {
  final int time;
  late Timer _timer;

  Delay(this.time) {
    _timer = Timer(time / 1000);
  }
  bool update(double dt) {
    _timer.update(dt);
    return _timer.finished;
  }
}

class Frame<T> extends Timeline<T> {
  final T value;
  final int timestamp;
  int? timeRun;

  Frame(this.value, this.timestamp);

  int get differenceTimeRun {
    if (timeRun != null) {
      return DateTime.now().millisecondsSinceEpoch - timeRun!;
    } else {
      return 0;
    }
  }
}

class EventQueue<T> {
  final int bufferSize;
  final int delay;
  late List<Timeline<T>> _timeLine;

  ValueChanged<T>? listen;

  int _currentIndex = 0;
  int _headIndex = 0;

  late Timeline<T> _current;

  EventQueue(this.delay, {this.bufferSize = 40}) {
    _timeLine = List<Timeline<T>>.filled(bufferSize, Empty<T>());
  }

  void add(T value, int timestamp) {
    if (isEmpty()) {
      _add(Delay(delay));
      _add(Frame<T>(value, timestamp));
      _current = _timeLine.first;
    } else {
      Frame<T> lastFrame = _timeLine[_getLastHeadIndex()] as Frame<T>;
      int delayLastFrame = timestamp - lastFrame.timestamp;
      if (lastFrame.timeRun == null) {
        _add(Delay(delayLastFrame));
      } else {
        int timeExecuted = lastFrame.differenceTimeRun;
        int delay = delayLastFrame - timeExecuted;
        if (delay > 0) {
          _add(Delay(delay.clamp(0, this.delay)));
        }
      }
      _add(Frame(value, timestamp));
    }
  }

  void run(double dt) async {
    if (_current is Delay<T>) {
      if ((_current as Delay).update(dt)) {
        _next();
      }
    } else if (_current is Frame<T>) {
      if ((_current as Frame).timeRun == null) {
        (_current as Frame).timeRun = DateTime.now().millisecondsSinceEpoch;
        listen?.call((_current as Frame).value);
      }
      _next();
    }
  }

  void _next() {
    if (haveNext()) {
      _currentIndex++;
      _current = _timeLine[_getIndex()];
    }
  }

  int _getIndex() {
    return _currentIndex % bufferSize;
  }

  int _getHeadIndex() {
    return _headIndex % bufferSize;
  }

  int _getLastHeadIndex() {
    return (_headIndex - 1) % bufferSize;
  }

  bool haveNext() {
    int nextIndex = (_currentIndex + 1) % bufferSize;
    return _timeLine[nextIndex] is! Empty;
  }

  bool isEmpty() {
    return _timeLine.where((element) => element is! Empty).isEmpty;
  }

  void _add(Timeline<T> timeline) {
    _timeLine[_getHeadIndex()] = timeline;
    _headIndex++;
    _timeLine[_getHeadIndex()] = Empty();
  }
}
