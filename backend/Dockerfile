# An example of using a custom Dockerfile with Dart Frog
# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

WORKDIR /app

# Resolve app dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .

# Generate a production build.
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Ensure packages are still up-to-date if anything has changed.
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM alpine:latest
RUN apk add --no-cache libc6-compat

# Copy the compiled server binary
COPY --from=build /app/build/bin/server /app/bin/server

# Create a non-root user
RUN addgroup -g 1001 -S dart && \
    adduser -S dart -u 1001

# Change ownership of the app directory to the dart user
RUN chown -R dart:dart /app

# Switch to the dart user
USER dart

# Expose the port
EXPOSE 8080

# Start the server.
CMD ["/app/bin/server"]