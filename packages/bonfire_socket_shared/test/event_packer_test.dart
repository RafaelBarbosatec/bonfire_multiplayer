// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:test/test.dart';

class _FakeSerializerProvider with EventSerializerProvider {
  _FakeSerializerProvider(this.serializer);

  @override
  final EventSerializer serializer;
}

class _FakeTypeAdapterProvider with BonfireTypeAdapterProvider {}

class _TestData {
  const _TestData({required this.x, required this.y, required this.name});

  final double x;
  final double y;
  final String name;

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'name': name};

  factory _TestData.fromMap(Map<String, dynamic> map) => _TestData(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        name: map['name'] as String,
      );
}

void main() {
  group('EventPacker (msgpack + binary frames)', () {
    late EventPacker packer;

    setUp(() {
      packer = EventPacker(
        serializerProvider: _FakeSerializerProvider(EventSerializerMsgpack()),
        typeAdapterProvider: _FakeTypeAdapterProvider()
          ..registerType<_TestData>(
            BTypeAdapter<_TestData>(
              toMap: (t) => t.toMap(),
              fromMap: _TestData.fromMap,
            ),
          ),
      );
    });

    test('packEvent returns raw bytes (binary frame, no base64)', () {
      final event = BEvent(event: 'test', time: 123, data: {'a': 1});
      final packed = packer.packEvent(event);
      expect(packed, isA<Uint8List>());
    });

    test('msgpack round-trip preserves event, time and nested data', () {
      final event = BEvent(
        event: 'player_move',
        time: 1780000000000000,
        data: {
          'x': 12.5,
          'y': -3.25,
          'name': 'rafa',
          'list': [1, 2, 3],
          'nested': {'ok': true, 'deep': {'v': 1.5}},
          'nothing': null,
        },
      );
      final restored = packer.unpackEvent(packer.packEvent(event));
      expect(restored.event, event.event);
      expect(restored.time, event.time);
      expect(restored.data, event.data);
    });

    test('unpackEvent accepts legacy base64 text frames (JSON)', () {
      final jsonPacker = EventPacker(
        serializerProvider: _FakeSerializerProvider(EventSerializerDefault()),
        typeAdapterProvider: _FakeTypeAdapterProvider(),
      );
      final event = BEvent(event: 'legacy', time: 42, data: {'k': 'v'});
      final legacyFrame = base64Encode(jsonEncode(event.toMap()));
      final restored = jsonPacker.unpackEvent(legacyFrame);
      expect(restored.event, 'legacy');
      expect(restored.time, 42);
      expect(restored.data, {'k': 'v'});
    });

    test('packData/unpackData round-trips typed objects', () {
      const data = _TestData(x: 1.5, y: 2.5, name: 'rafa');
      final packed = packer.packData<_TestData>(data);
      final restored = packer.unpackData<_TestData>(packed);
      expect(restored.name, 'rafa');
      expect(restored.x, 1.5);
      expect(restored.y, 2.5);
    });
  });
}
