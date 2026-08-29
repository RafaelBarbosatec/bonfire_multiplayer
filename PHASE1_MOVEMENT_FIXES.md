# Fase 1 - Correções de Movimento (Smooth Movement Fixes)

Correções cirúrgicas para eliminar a "muita correção" no movimento de jogadores remotos.

## Problemas Corrigidos

### 1. Broadcast do servidor a ~1Hz durante movimento contínuo
**Causa**: `GameTimer(duration: 1)` no mixin `Movement` só chamava `requestUpdate()` 1x por segundo durante movimento contínuo (a direção não muda). O cliente recebia updates a cada ~1s: interpolação de 30-120ms + ~880ms parado + correção visual de 150-350ms.
**Fix**: `GameTimer(duration: 0.05)` → broadcast de posição a **20Hz** durante o movimento.

### 2. Delta detection com `toInt()` (staircase)
**Causa**: o hash do `MapStateTracker` usava `position.toInt()`, então mudanças sub-pixel não eram detectadas e eram "despejadas" em micro-teleportes.
**Fix**: hash com precisão float completa (`position.x`, `position.y`).

### 3. Dois sistemas brigando pela posição do remoto
**Causa**: `UpdateMovementMixin` chamava `moveFromDirection()` (o motor do Bonfire movia o componente via `translate` → `position.add`) E o `SmoothMovementMixin` interpola com `position.setFrom` — ambos escreviam a posição → jitter constante.
**Fix**: `translate()` virou **no-op** nos componentes remotos (`MyRemotePlayer`, `MyRemoteEnemy`). A posição é controlada 100% pela interpolação; o motor só dispara a animação.

### 4. Interpolação com "recomeço" (sem render buffer)
**Causa**: a cada update, a interpolação recomeçava de `position.clone()` — com jitter de rede, o progresso ficava inconsistente.
**Fix**: **render buffer** — os estados do servidor são enfileirados e o entity é renderizado com atraso fixo de 80ms, interpolando sempre entre dois estados conhecidos na timeline (técnica padrão de networked movement).

### 5. Correções longas demais (percepção de "muita correção")
**Causa**: idle usava `MoveEffect` de 150-350ms; teleportes (>64px) também animavam.
**Fix**: idle agora faz snap suave de **60ms**; teleporte real (>128px, respawn/troca de mapa) é **instantâneo** (sem animação).

### 6. Latência artificial de input no servidor + bug de relógio
**Causa**: `BonfireSocket` com `bufferDelayEnabled: true` fazia todo input passar pelo `EventQueue` com delay de RTT/2 (lag de entrada artificial). Além disso, o servidor convertia o timestamp do **cliente** como se fosse do servidor (offset duplicado).
**Fix**: `bufferDelayEnabled: false` no servidor (inputs chegam direto ao game loop) + `Frame` usa o **tempo de recebimento do servidor** (`DateTime.now()`).

## Arquivos Modificados

### Servidor
- `packages/bonfire_server/lib/src/mixins/movement.dart` — broadcast 20Hz
- `game_server/src/game/state_tracker.dart` — hash com precisão float
- `game_server/src/infrastructure/websocket/bonfire_websocket.dart` — `bufferDelayEnabled: false`
- `packages/bonfire_socket_server/lib/src/socket_channel.dart` — timestamp de recebimento (fix relógio)

### Cliente
- `game_client/lib/util/smooth_movement_mixin.dart` — render buffer + snap curto + teleporte instantâneo
- `game_client/lib/components/my_remote_player/my_remote_player.dart` — `translate` no-op
- `game_client/lib/components/my_remote_enemy/my_remote_enemy.dart` — `translate` no-op
- `game_client/lib/components/my_player/my_player.dart` — correção idle mais curta (60-150ms)
- `game_client/lib/util/update_movement_mixin.dart` — comentários/contrato atualizado

### CI
- `.github/workflows/ci.yml` — analyze + test dos pacotes Dart + `flutter analyze` do client

## Próximas Fases
- **Fase 2**: predição real com reconciliação por `inputId` (o `InputEvent` já existe, não é usado)
- **Fase 3**: protocolo — msgpack + binary frames, serialização única por broadcast, `MoveEvent.time` como int
- **Fase 4**: fixed timestep, snapshot/rollback, rooms por mapa, anti-cheat
