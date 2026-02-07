// ignore_for_file: avoid_print

import 'package:bonfire_socket_shared/src/util/event_queue.dart';
import 'package:bonfire_socket_shared/src/util/time_sync.dart';
import 'package:test/test.dart';

/// Mock TimeSync for testing without actual server synchronization
class MockTimeSync extends TimeSync {
  int _mockRoundTripTime = 0;
  Duration _mockServerDifference = Duration.zero;

  void setRoundTripTime(int microseconds) {
    _mockRoundTripTime = microseconds;
  }

  void setServerDifference(Duration difference) {
    _mockServerDifference = difference;
  }

  @override
  int get roundTripTime => _mockRoundTripTime;

  @override
  DateTime serverTimestampToLocal(int serverTimestamp) {
    final serverTime = DateTime.fromMicrosecondsSinceEpoch(serverTimestamp);
    return serverTime.subtract(_mockServerDifference);
  }
}

void main() {
  group('EventQueue', () {
    late MockTimeSync timeSync;
    late List<String> receivedEvents;
    late List<DateTime> receivedTimes;
    late EventQueue<String> eventQueue;

    setUp(() {
      timeSync = MockTimeSync();
      receivedEvents = [];
      receivedTimes = [];
    });

    test('events are delivered in correct order based on timestamps', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events in wrong order but with correct timestamps
      eventQueue.add(Frame('Event 3', baseTime + 2000000)); // +2s
      eventQueue.add(Frame('Event 1', baseTime)); // 0s
      eventQueue.add(Frame('Event 2', baseTime + 1000000)); // +1s

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Events should be reordered by timestamp
      expect(receivedEvents, ['Event 1', 'Event 2', 'Event 3']);
    });

    test('events are delivered with correct timing intervals', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events with 500ms interval
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 2', baseTime + 500000)); // +500ms
      eventQueue.add(Frame('Event 3', baseTime + 1000000)); // +1000ms

      // Wait for all events to be processed
      await Future.delayed(const Duration(milliseconds: 1500));

      expect(receivedEvents.length, 3);
      expect(receivedEvents, ['Event 1', 'Event 2', 'Event 3']);

      // Check timing intervals (with some tolerance for test execution)
      if (receivedTimes.length >= 2) {
        final interval1 = receivedTimes[1].difference(receivedTimes[0]).inMilliseconds;
        expect(interval1, greaterThan(400)); // At least 400ms
        expect(interval1, lessThan(600)); // At most 600ms
      }

      if (receivedTimes.length >= 3) {
        final interval2 = receivedTimes[2].difference(receivedTimes[1]).inMilliseconds;
        expect(interval2, greaterThan(400)); // At least 400ms
        expect(interval2, lessThan(600)); // At most 600ms
      }
    });

    test('events with 2-second interval are delivered correctly', () async {
      // This is the specific example from the problem statement
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add two events with 2-second interval
      eventQueue.add(Frame('Event A', baseTime));
      eventQueue.add(Frame('Event B', baseTime + 2000000)); // +2s

      // Wait for both events
      await Future.delayed(const Duration(milliseconds: 2500));

      expect(receivedEvents, ['Event A', 'Event B']);

      // Verify 2-second interval (with tolerance)
      if (receivedTimes.length >= 2) {
        final interval = receivedTimes[1].difference(receivedTimes[0]).inMilliseconds;
        expect(interval, greaterThan(1900)); // At least 1.9s
        expect(interval, lessThan(2200)); // At most 2.2s (including 100ms cap per delay)
      }
    });

    test('out-of-order events within reorder window are reordered', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
        },
        enabled: true,
        maxReorderWindow: const Duration(milliseconds: 200),
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events with small out-of-order difference (within 200ms window)
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 3', baseTime + 200000)); // +200ms
      eventQueue.add(Frame('Event 2', baseTime + 100000)); // +100ms (out of order)

      await Future.delayed(const Duration(milliseconds: 500));

      // Should be reordered
      expect(receivedEvents, ['Event 1', 'Event 2', 'Event 3']);
    });

    test('out-of-order events outside reorder window are dropped', () async {
      final droppedEvents = <String>[];
      
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
        },
        enabled: true,
        maxReorderWindow: const Duration(milliseconds: 100),
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events with large out-of-order difference (outside 100ms window)
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 3', baseTime + 500000)); // +500ms
      eventQueue.add(Frame('Event 2', baseTime + 50000)); // +50ms (>100ms behind Event 3)

      await Future.delayed(const Duration(milliseconds: 700));

      // Event 2 should be dropped as it's too far out of order
      expect(receivedEvents, ['Event 1', 'Event 3']);
      expect(receivedEvents, isNot(contains('Event 2')));
    });

    test('delay calculations preserve timestamp intervals', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events with specific intervals
      eventQueue.add(Frame('A', baseTime));
      eventQueue.add(Frame('B', baseTime + 100000)); // +100ms
      eventQueue.add(Frame('C', baseTime + 300000)); // +300ms
      eventQueue.add(Frame('D', baseTime + 600000)); // +600ms

      await Future.delayed(const Duration(milliseconds: 900));

      expect(receivedEvents, ['A', 'B', 'C', 'D']);

      // Verify intervals match timestamps
      if (receivedTimes.length >= 4) {
        // A to B should be ~100ms (capped at 100ms)
        final ab = receivedTimes[1].difference(receivedTimes[0]).inMilliseconds;
        expect(ab, greaterThan(80));
        expect(ab, lessThan(120));

        // B to C should be ~200ms (capped at 100ms per chunk)
        final bc = receivedTimes[2].difference(receivedTimes[1]).inMilliseconds;
        expect(bc, greaterThan(180));
        expect(bc, lessThan(220));

        // C to D should be ~300ms (capped at 100ms per chunk)
        final cd = receivedTimes[3].difference(receivedTimes[2]).inMilliseconds;
        expect(cd, greaterThan(280));
        expect(cd, lessThan(320));
      }
    });

    test('disabled queue delivers events immediately', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: false, // Disabled queue
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;
      final startTime = DateTime.now();

      // Add events with delays
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 2', baseTime + 1000000)); // +1s

      // Should be immediate
      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents, ['Event 1', 'Event 2']);

      // Events should arrive almost immediately (no delay respected)
      final totalTime = DateTime.now().difference(startTime).inMilliseconds;
      expect(totalTime, lessThan(100));
    });

    test('events arrive in sequence maintain correct order', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add many events in sequence
      for (int i = 0; i < 10; i++) {
        eventQueue.add(Frame('Event $i', baseTime + (i * 50000))); // 50ms intervals
      }

      await Future.delayed(const Duration(milliseconds: 700));

      // Should maintain order
      for (int i = 0; i < 10; i++) {
        expect(receivedEvents[i], 'Event $i');
      }
    });

    test('RTT delay is applied correctly', () async {
      // Set mock RTT to 100ms (50ms will be added as buffer)
      timeSync.setRoundTripTime(100000); // 100ms in microseconds

      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add two events
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 2', baseTime + 200000)); // +200ms

      await Future.delayed(const Duration(milliseconds: 400));

      expect(receivedEvents, ['Event 1', 'Event 2']);
      
      // The interval should include the RTT buffer (50ms) plus event interval (200ms)
      // But delays are capped at 100ms, so multiple chunks
      if (receivedTimes.length >= 2) {
        final interval = receivedTimes[1].difference(receivedTimes[0]).inMilliseconds;
        expect(interval, greaterThan(180));
        expect(interval, lessThan(300));
      }
    });

    test('max delay cap prevents excessive blocking', () async {
      eventQueue = EventQueue<String>(
        timeSync: timeSync,
        listen: (event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        },
        enabled: true,
      );

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      // Add events with very large interval
      eventQueue.add(Frame('Event 1', baseTime));
      eventQueue.add(Frame('Event 2', baseTime + 500000)); // +500ms

      await Future.delayed(const Duration(milliseconds: 700));

      expect(receivedEvents, ['Event 1', 'Event 2']);

      // Even with 500ms interval, max 100ms cap should apply multiple times
      // So total delay should still be around 500ms but in 100ms chunks
      if (receivedTimes.length >= 2) {
        final interval = receivedTimes[1].difference(receivedTimes[0]).inMilliseconds;
        expect(interval, greaterThan(400));
        expect(interval, lessThan(600));
      }
    });
  });
}
