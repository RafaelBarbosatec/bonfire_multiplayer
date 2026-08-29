# syntax=docker/dockerfile:1

# ============================================================================
#  Dockerfile self-build (multi-stage)
#
#  O `dart_frog build` acontece DENTRO do container — não precisa rodar na
#  sua máquina nem subir a pasta `build/` no git.
#
#  Contexto de build: a RAIZ do monorepo (o game_server depende de packages
#  locais via path: shared_events, bonfire_server, bonfire_socket_server,
#  bonfire_socket_shared).
#
#    docker build -f Dockerfile -t game_server .
#
#  Stage 1 (build):  instala o Dart Frog CLI, roda `dart_frog build` e
#                    compila o servidor AOT (`dart compile exe`).
#  Stage 2 (runtime): imagem mínima (scratch) com o binário + runtime.
# ============================================================================

FROM dart:stable AS build

WORKDIR /app

# Dart Frog CLI — necessário para gerar a pasta build/ do projeto.
RUN dart pub global activate dart_frog_cli
ENV PATH="$PATH:/root/.pub-cache/bin"

# --- Camada de dependências (cache-friendly) -------------------------------
# Copia só os pubspecs primeiro: mudanças de código não invalidam o `pub get`.
COPY game_server/pubspec.yaml game_server/pubspec_overrides.yaml ./game_server/
COPY shared_events/pubspec.yaml ./shared_events/
COPY packages/bonfire_server/pubspec.yaml ./packages/bonfire_server/
COPY packages/bonfire_socket_server/pubspec.yaml ./packages/bonfire_socket_server/
COPY packages/bonfire_socket_shared/pubspec.yaml ./packages/bonfire_socket_shared/

RUN cd game_server && dart pub get

# --- Código fonte completo do monorepo --------------------------------------
COPY . .

# Gera game_server/build/ (bin/server.dart, public/, routes/, ...)
RUN cd game_server && dart_frog build

# --- Compila o binário AOT a partir da build gerada -------------------------
WORKDIR /app/game_server/build
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# ============================================================================
#  Runtime — imagem mínima (mesma estratégia do template oficial do Dart Frog)
# ============================================================================
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/game_server/build/bin/server /app/bin/
COPY --from=build /app/game_server/build/public /public

EXPOSE 8080
CMD ["/app/bin/server"]
