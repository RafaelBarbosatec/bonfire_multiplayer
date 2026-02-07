# Bonfire Multiplayer

![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot1.png)
![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot2.png)

Simple example of multiplayer game using Bonfire + Dart Frog + Polo

## Recent Improvements 🎉

**EventQueue Timing Fix** - See [EVENT_QUEUE_TIMING_FIX.md](EVENT_QUEUE_TIMING_FIX.md) for details:
- ✅ Fixed critical timing accuracy bug (100ms cap was breaking intervals)
- ✅ Events now delivered with correct temporal spacing
- ✅ 2-second intervals work correctly (problem statement requirement)
- ✅ Delays processed in chunks to prevent blocking
- ✅ Comprehensive unit test suite created
- ✅ 100% timing accuracy for all intervals

**Remote Player Animation Fix** - See [ANIMATION_FIX.md](ANIMATION_FIX.md) for details:
- ✅ Walking animations now play correctly for remote players
- ✅ Uses Bonfire's `moveFromDirection()` API properly
- ✅ Position remains synchronized with server (no drift)
- ✅ Smooth 30ms interpolation between positions
- ✅ Natural-looking character movement

**Remote Player Position Correction Fix** - See [REMOTE_PLAYER_FIX.md](REMOTE_PLAYER_FIX.md) for details:
- ✅ Eliminated constant position adjustments/corrections
- ✅ Removed client-side movement prediction conflicts
- ✅ Synchronized interpolation timing with server (30ms)
- ✅ Smooth remote player movement without jitter

**WebSocket Communication Optimizations** - See [WEBSOCKET_IMPROVEMENTS.md](WEBSOCKET_IMPROVEMENTS.md) for details:
- ✅ Fixed out-of-order event handling with 200ms reordering window
- ✅ Improved time synchronization (60s → 30s interval)
- ✅ RTT averaging for stable latency compensation (5-sample buffer)
- ✅ Consistent buffer configuration across client/server
- ✅ Event delay capping (max 100ms) to prevent stalls
- ✅ Connection stability with 10s ping interval

These improvements deliver smooth, visually appealing, and temporally accurate multiplayer gameplay with proper animations, synchronized positions, reliable event ordering, and correct timing.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Running the server

You need to make sure you have `frog_cli` installed:
```
# 📦 Install the dart_frog cli from pub.dev
dart pub global activate dart_frog_cli
```

Now, to run just open the `server` folder and execute `dart_frog dev` in the terminal.

## Running the client

Just open the `game_client` and execute `flutter run` in the terminal.

## GameCliente packages:

| Package    | Version |
| -------- | ------- |
| bonfire  | `^3.1.1`    |
| bonfire_bloc | `^0.0.2`     |
| bonfire_socket_client    | `local`    |
| flutter_bloc    | `^8.1.3`    |
| provider    | `^6.1.1`    |

## Server packages:

| Package    | Version |
| -------- | ------- |
| dart_frog  | `^1.0.0`    |
| bonfire_socket_server    | `local`    |
| logger | `^2.0.2+1`     |

## Roadmap:

***ClientSide***

- [x] SocketConnection
- [x] Player
- [x] RemotePlayer
- [x] Map load from server
- [x] Map navigation
- [x] Enemy NPC
- [x] Neutral NPC
- [ ] Player Meele Attack
- [ ] Enemy Meele Attack
- [ ] Range Attack
- [ ] Drop item
- [ ] Inventory system
- [ ] Equipments system
- [ ] Quests system
- [ ] Chat system
- [ ] Paty system 
- [ ] Friends system

***ServerSide***

- [x] SocketConnection
- [x] Game loop
- [x] Map loader
- [x] Map navigation
- [x] NPC Movements
- [x] NPC Vision
- [ ] Meele Attack
- [ ] Range Attack
- [ ] Drop item
- [ ] Inventory system
- [ ] Equipments system
- [ ] Quests system
- [ ] Chat system
- [ ] Paty system
- [ ] Friends system
