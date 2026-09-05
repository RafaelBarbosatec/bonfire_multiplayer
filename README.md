# Bonfire Multiplayer

[![CI](https://img.shields.io/github/actions/workflow/status/RafaelBarbosatec/bonfire_multiplayer/ci.yml?branch=main&label=CI&logo=github)](https://github.com/RafaelBarbosatec/bonfire_multiplayer/actions)

**Open-world MMORPG template** built with [Bonfire](https://github.com/RafaelBarbosatec/bonfire) (Flutter) + [Dart Frog](https://dartfrog.vgv.dev/) + WebSocket, with a **server-authoritative** architecture: the server owns the world state and every player's position; clients predict, interpolate and reconcile.

> A shared, no-rooms world (Ragnarok Online vibe): maps with portals, NPC enemies, auth with characters, and persistent character position — re-enter and you're exactly where you left off.

## ✨ Highlights

- 🕹️ **Server-authoritative movement** — inputs (`MoveEvent`) are validated and integrated on the server game loop; deltas are broadcast per map only when something changes (`MapStateTracker`).
- 🧠 **Client-side prediction + reconciliation** — the local player moves instantly; `lastInputId` echoes let the client correct itself only when the server is truly ahead, avoiding "rubber-banding".
- 🎯 **Buttery remote players** — render buffer interpolates on the **server timeline** (clock-synced via `TimeSync`), with an **adaptive render delay** (measured from the state arrival age) + short extrapolation when the buffer runs dry. No more stutter/jumps on real networks.
- 🗜️ **Compact binary protocol** — msgpack envelope (`BEvent`), serialized **once** per broadcast and sent raw to every player in the map (single pass, no per-client inflation).
- 🔐 **Auth + characters** — sign up/in by e-mail (SHA-256 + per-user salt), JWT issued/validated by the server, REST + WebSocket sharing the same data. Characters have nickname + skin (`boy`/`girl`); joining with a JWT spawns you at the character's **saved position**.
- 🗺️ **Tiled worlds served by the server** — the client loads maps over HTTP (`/maps/...`) and crosses **portals/gateways** between maps (florest ↔ desert) with seamless `JoinMap` transitions.
- ⚔️ **Enemy NPCs** — server-driven movement/vision, rendered on clients as remote entities (collision blocks the local player).
- 🎨 **Ragnarok-inspired UI** — login/character-select screens in landscape with ornate panels; game is locked to landscape.

## 🖼️ Screenshots

![Screenshot 1](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot1.png)
![Screenshot 2](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire_multiplayer/main/imgs/screenshot2.png)

## 📦 Repository layout

Monorepo — every Dart package lives here and is wired with `path:` dependencies:

| Path | What it is |
| --- | --- |
| `game_server/` | **Dart Frog server**: REST auth API + the authoritative game loop (`GameServer`, maps, players, NPCs) |
| `game_client/` | **Flutter client** (Bonfire 4.0.0-beta): login → character select → world |
| `shared_events/` | Protocol models shared by server & client (`ComponentStateModel`, `MoveEvent`, `GameStateModel`, `JoinMapEvent`...) with hand-written `toMap/fromMap` |
| `packages/bonfire_server/` | Headless game engine (components, maps, movement, collision) |
| `packages/bonfire_socket_shared/` | Transport envelope (`BEvent`), event serializer (msgpack/JSON), `TimeSync` clock sync |
| `packages/bonfire_socket_client/` | WebSocket client (binary frames, dispatch imediato — no reorder queue) |
| `packages/bonfire_socket_server/` | WebSocket server layer for Dart Frog |
| `Dockerfile-server` | Multi-stage **self-build** image for `game_server` (builds inside the container) |
| `.github/workflows/ci.yml` | CI: `dart analyze`/tests on every Dart package + `flutter analyze` on the client |

## 🚀 Getting started

### 1. Run the server

Requires the [Dart Frog CLI](https://pub.dev/packages/dart_frog_cli) (one-time):

```sh
dart pub global activate dart_frog_cli
```

Then, from the monorepo root:

```sh
cd game_server
dart pub get
dart_frog dev          # REST + WebSocket on http://localhost:8080
```

> The server also serves the Tiled map files (`/maps/map1/florest.tmj`, ...) from `game_server/public/`.

**Docker** (self-build — needs no Dart Frog CLI locally, builds inside the container):

```sh
docker build -f Dockerfile-server -t bonfire-server .
docker run -p 8080:8080 bonfire-server
```

> ⚠️ Data (users/characters) lives in an **in-memory datasource** — a server restart wipes it. A real database is on the roadmap.

### 2. Run the client

```sh
cd game_client
flutter pub get
flutter run           # app is locked to landscape
```

The client points at `http://127.0.0.1:8080` by default (`game_client/lib/util/enviroment.dart`, `LocalInviroment`). To hit a deployed server, switch to `ServerInviroment` in `game_client/lib/bootstrap_injector.dart`.

### 3. Play

1. **Sign up** (e-mail + password) or log in — or enter anonymously ("entrar sem conta").
2. **Create a character**: pick a nickname and a skin (`boy`/`girl`).
3. **Enter the world**: your character spawns at its saved spot. Move with the joystick/keyboard and explore; other players and enemy NPCs appear around you in real time.
4. Walk through the golden **portals** to travel between maps.

## 🧭 Roadmap

### ✅ Implemented

**Client**
- [x] WebSocket transport (binary msgpack, immediate dispatch)
- [x] Local player with **prediction & reconciliation** (`lastInputId`)
- [x] Remote players/enemies: **smooth interpolation** on the server timeline (adaptive render delay + extrapolation, TimeSync)
- [x] Tiled map loading from the server + portal navigation
- [x] Login / sign-up screens (e-mail + password)
- [x] Character select screen — **Ragnarok-inspired**, landscape-first
- [x] Enemy NPC rendering (server-driven movement)
- [x] Bonfire **4.0.0-beta.13** (collision API, `bonfire_bloc` vendored until a 4.x release)
- [x] **Game locked to landscape**

**Server**
- [x] Game loop + per-map delta broadcast (`MapStateTracker`, only on change)
- [x] Server-authoritative movement (input validation, 20–33 Hz position integration)
- [x] Tiled map loading, collision, portals/gateways (florest ↔ desert)
- [x] NPCs: movement + vision
- [x] **Auth**: sign up/in, password hashing (salt), JWT issue/validate (REST **and** WebSocket join)
- [x] **Characters**: create/list, skins
- [x] **Position persistence** (map change / disconnect / 5s safety timer)

### 🎯 Next milestone — Player attributes & leveling

- [ ] **HP, Stamina and Mana (MP)** — authoritative on the server, synced to clients
- [ ] **Experience & level**: gain XP → every **100 XP** you level up (XP resets, level +1)
- [ ] Attributes HUD on the client (life/stamina/mana bars + level)
- [ ] Basic combat hooking into life (melee → damage → XP)

### 🔭 Later

| Client | Server |
| --- | --- |
| Melee / ranged attacks, damage feedback, death & respawn | Combat validation (melee/range), damage, death/respawn |
| Inventory & equipment | Drops, inventory & equipment |
| Quests, chat, party, friends | Quests, chat, party, friends |
| — | Real database (currently in-memory) |

## 📚 Documentation

Historical design docs live at the repo root:

- `PHASE1_MOVEMENT_FIXES.md` — first movement/interpolation iteration
- `PHASE2_CLIENT_PREDICTION.md` — client-side prediction & reconciliation design
- `MOVIMENTO_FLUIDO_IMPROVEMENTS.md` — smoothing/fluidity pass

## 🧰 Tech stack

| Client | Version |
| --- | --- |
| [bonfire](https://pub.dev/packages/bonfire) | `^4.0.0-beta.13` |
| flutter_bloc / equatable / get_it / http | `^8.1.3` / `^2.0.5` / `^8.0.3` / `^1.2.2` |
| bonfire_socket_client | `local` (monorepo) |

| Server | Version |
| --- | --- |
| dart_frog | `^1.0.0` |
| dart_frog_auth | `^1.2.0` |
| logger | `^2.0.2+1` |
| bonfire_server / bonfire_socket_server | `local` (monorepo) |

## 🧑‍💻 Contributing

PRs are welcome — CI (`dart analyze` + tests on packages, `flutter analyze --no-fatal-infos` on the client) must stay green. This is an active project: feel free to open an issue to discuss a feature before a big PR.
