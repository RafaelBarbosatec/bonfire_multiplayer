// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:shared_events/shared_events.dart';

class ChangeMapEvent {
  final String pathMap;
  final ComponentStateModel state;

  ChangeMapEvent({required this.pathMap, required this.state});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pathMap': pathMap,
      'state': state.toMap(),
    };
  }

  factory ChangeMapEvent.fromMap(Map<String, dynamic> map) {
    return ChangeMapEvent(
      pathMap: map['pathMap'] as String,
      state: ComponentStateModel.fromMap(map['state'] as Map<String, dynamic>),
    );
  }
}
