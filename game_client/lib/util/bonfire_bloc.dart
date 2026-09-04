// Vendored copy of the `bonfire_bloc` package (by Rafael Barbosatec,
// https://github.com/RafaelBarbosatec/bonfire_bloc) — both mixins are kept
// byte-for-byte equivalent. The pub.dev version (0.0.2) pins `bonfire: ^3.x`,
// which cannot be solved together with bonfire 4.x, so the two small mixins
// live here until bonfire_bloc publishes a 4.x release.
//
// Original license: MIT.

import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Adds [Bloc] access and listening to a [GameComponent]
mixin BonfireBlocListenable<B extends BlocBase<S>, S> on GameComponent {
  late S _state;
  late StreamSubscription<S> _subscription;
  late B _bloc;
  B? _blocOverride;

  /// Returns the bloc that this component is reading from once the component
  /// has been mounted.
  B get bloc {
    assert(
      isMounted,
      'Cannot access the bloc instance before it has been mounted.',
    );
    return _bloc;
  }

  /// Explicitly set the bloc instance which the component will be listening to.
  /// This is useful in cases where the bloc being listened to
  /// has not be provided via [BlocProvider].
  set bloc(B bloc) {
    assert(
      _blocOverride == null,
      'Cannot update the bloc instance once it has been set.',
    );
    _blocOverride = bloc;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    var bloc = _blocOverride;
    if (bloc == null) {
      _blocOverride = bloc = BlocProvider.of(context);
    }
    _bloc = bloc;
    _state = bloc.state;
    onInitialState(_state);
    _subscription = bloc.stream.listen((newState) {
      if (_state != newState) {
        final callNewState = listenWhen(_state, newState);
        _state = newState;

        if (callNewState) {
          onNewState(newState);
        }
      }
    });
  }

  /// Override this to make [onNewState] be called only when
  /// a certain state change happens.
  ///
  /// Default implementation returns true.
  bool listenWhen(S previousState, S newState) => true;

  /// Listener called every time a new state is emitted to this component.
  ///
  /// Default implementation is a no-op.
  void onNewState(S state) {}

  /// Called only once with the initial state provided.
  ///
  /// Default implementation is a no-op.
  void onInitialState(S state) {}

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    _subscription.cancel();
  }
}

/// Adds [Bloc] access to a [GameComponent].
///
/// Useful for components that needs to only read
/// a bloc current state or to trigger an event on it
mixin BonfireBlocReader<B extends BlocBase> on GameComponent {
  late B _bloc;

  /// Returns the bloc that this component is reading from
  B get bloc => _bloc;

  @override
  void onMount() {
    _bloc = BlocProvider.of(context);
    super.onMount();
  }
}
