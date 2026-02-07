# Bonfire Multiplayer

![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot1.png)
![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot2.png)

Simple example of multiplayer game using Bonfire + Dart Frog + Polo

## Recent Improvements 🎉

**WebSocket Communication Optimizations** - See [WEBSOCKET_IMPROVEMENTS.md](WEBSOCKET_IMPROVEMENTS.md) for details:
- ✅ Fixed out-of-order event handling with 200ms reordering window
- ✅ Improved time synchronization (60s → 30s interval)
- ✅ RTT averaging for stable latency compensation (5-sample buffer)
- ✅ Consistent buffer configuration across client/server
- ✅ Event delay capping (max 100ms) to prevent stalls
- ✅ Connection stability with 10s ping interval

These improvements significantly reduce event delays and ensure proper event ordering, even on unstable networks.

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
