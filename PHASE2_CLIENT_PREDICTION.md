# Fase 2 - Predição com Reconciliação (Client-Side Prediction)

Fecha o loop de predição do cliente: inputs com `inputId` sequencial, buffer
de inputs pendentes e reconciliação quando o servidor confirma.

## O que foi implementado

### Protocolo (shared_events)
- `MoveEvent` ganhou o campo **`inputId`** (int sequencial do input do cliente).
- `ComponentStateModel.lastInputId` deixou de ser `final` — o servidor o
  atualiza a cada input processado (eco de confirmação).

### Servidor (game_server)
- `Player._listenMove` agora seta `state.lastInputId = data.inputId` ao
  processar cada `MoveEvent` — o delta seguinte carrega a confirmação.
- `MapStateTracker._calculateHash` inclui `lastInputId` no hash para que a
  confirmação seja propagada mesmo sem mudança de posição/direção.

### Cliente (game_client)
- **`MyPlayerBloc`**: gera `inputId` sequencial, mantém um **buffer de inputs
  pendentes** (`_pendingInputs` com `InputEvent`), e na reconciliação remove
  os inputs já confirmados pelo servidor (`id <= lastInputId`).
- **`MyPlayerState`**: novo campo `hasPendingInputs` — true enquanto existem
  inputs não confirmados.
- **`MyPlayer.onNewState`**: **só corrige a posição quando NÃO há inputs
  pendentes**. Enquanto o servidor está atrás (lag), nenhuma correção é feita
  (corrigir nesse momento causaria o "puxão" visível).
- **`InputEvent.getPredictedPosition`**: suporte a direções diagonais
  (reduction de cos(45°), igual ao servidor).
- **`BonfireSocketClient` com `bufferDelayEnabled: false`**: o atraso de
  render é responsabilidade do `SmoothMovementMixin` (render buffer fixo de
  80ms). O buffer no transporte empilhava um atraso variável de RTT/2 em cima
  do render buffer (atraso visual = RTT/2 + 80ms) — redundante e imprevisível.

## Benefício

O jogador local anda com predição imediata e o servidor ecoa a posição real.
As correções visíveis agora só acontecem quando há **desacordo real** (ex:
colisão no servidor) e **nunca durante lag** (inputs pendentes) — eliminando
a principal fonte de "puxão" no personagem local.

## Próximas Fases
- **Fase 3**: protocolo — msgpack + binary frames, serialização única por
  broadcast, `MoveEvent.time` como int µs (hoje ISO string).
- **Fase 4**: fixed timestep, snapshot/rollback p/ lag compensation, rooms
  por mapa, anti-cheat.
