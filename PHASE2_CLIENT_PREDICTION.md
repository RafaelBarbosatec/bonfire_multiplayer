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

### Interpolação na timeline do servidor
- **Servidor preenche `state.serverTimestamp`** (µs epoch) a cada movimento/
  parada/join — o momento em que a posição é verdadeira no relógio do servidor.
- **Cliente**: o `TimeSync` é exposto na cadeia (`WebsocketProvider.timeSync`
  → `GameEventManager.timeSync`), e os widgets remotos convertem o
  `serverTimestamp` para a timeline local antes de passar ao
  `SmoothMovementMixin`. O render buffer interpola no **tempo do servidor**,
  imune ao jitter da rede (antes usava o tempo de chegada — rajadas de rede
  distorciam o ritmo do movimento).

### Remoção do EventQueue (transporte)
- **`EventQueue` removido** do `bonfire_socket_shared`, `bonfire_socket_client`
  e `bonfire_socket_server`. Motivos:
  - **Ordem**: o WebSocket (TCP) já garante entrega em ordem — o reorder
    window era desnecessário.
  - **Tempo de emissão ≠ tempo de chegada**: o TCP não preserva intervalos;
    mas "reproduzir" eventos com atraso não é a técnica para movimento —
    quem resolve jitter é a interpolação com render buffer na camada de
    render (usando `serverTimestamp`), não um buffer no transporte.
  - O buffer no transporte empilhava um atraso variável de RTT/2 e o servidor
    não deve atrasar inputs (latência de entrada artificial).
- Parâmetro `bufferDelayEnabled` removido dos construtores de client e server.
- `TimeSync` **mantido** (necessário para converter `serverTimestamp`).

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
