// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'mixins/contact_sensor.dart';

abstract class GameComponent {
  GameComponent({
    List<GameComponent>? components,
  }) : components = components ?? [];

  final List<GameComponent> _compsToRemove = [];
  GameComponent? parent;
  List<GameComponent> components;

  void onUpdate(double dt) {
    for (final element in components) {
      element.onUpdate(dt);
    }
    if (_compsToRemove.isNotEmpty) {
      for (final comp in _compsToRemove) {
        components.remove(comp);
      }
      _compsToRemove.clear();
      requestUpdate();
    }
  }

  void onRequestUpdate(GameComponent comp) {}

  void requestUpdate() {
    if (parent != null) {
      parent?.requestUpdate();
      parent?.onRequestUpdate(this);
    } else {
      onRequestUpdate(this);
    }
  }

  void removeFromParent() {
    parent?.remove(this);
  }

  void add(GameComponent comp) {
    comp.parent = this;
    components.add(comp);
    requestUpdate();
  }

  void addAll(List<GameComponent> compList) {
    compList.forEach(add);
  }

  void remove(GameComponent comp) {
    _compsToRemove.add(comp);
  }

  bool checkContactWithParents(ContactSensor comp) {
    for (final sensor in components.whereType<ContactSensor>()) {
      if (sensor != comp) {
        if (sensor.checkContact(comp)) {
          return true;
        }
      }
    }
    return parent?.checkContactWithParents(comp) ?? false;
  }
}
