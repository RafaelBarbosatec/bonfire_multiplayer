# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

WORKDIR /app

# Install Dart Frog CLI globally and add it to PATH
RUN dart pub global activate dart_frog_cli \
    && echo "export PATH=\"\$PATH:\$HOME/.pub-cache/bin\"" >> /etc/profile.d/dart_frog.sh
ENV PATH="/root/.pub-cache/bin:${PATH}"

# Copy project structure maintaining relative paths
COPY . .

# Set working directory to game_server for build
WORKDIR /app/game_server

# Build the production-ready Dart Frog application
RUN dart_frog build

# Switch to build output folder for dependency resolution & compilation
WORKDIR /app/game_server/build

# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/game_server/bin/server /app/bin/
COPY --from=build /app/game_server/public /public

# Start server.
CMD ["/app/bin/server"]