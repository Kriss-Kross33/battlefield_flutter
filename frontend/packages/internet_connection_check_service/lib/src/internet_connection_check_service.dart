import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';

/// InternetConnectionCheckService is a service that checks
/// if the device is connected to the internet.
enum ConnectionStatus {
  /// The internet is slow
  slow,

  /// The device is connected to the internet.
  connected,

  /// The device is not connected to the internet.
  disconnected,
}

/// {@template internet_connection_check_service}
/// check internet connection package
/// {@endtemplate}
class InternetConnectionCheckService {
  /// {@macro internet_connection_check_service}]

  /// check stream internet connection
  ///
  /// return [ConnectionStatus] which indicates internet connection status
  Stream<ConnectionStatus> checkInternetConnection() async* {
    final customInstance = InternetConnectionChecker.instance;

    yield* customInstance.onStatusChange.asyncMap((status) {
      switch (status) {
        case InternetConnectionStatus.slow:
          return ConnectionStatus.slow;
        case InternetConnectionStatus.connected:
          return ConnectionStatus.connected;
        case InternetConnectionStatus.disconnected:
          return ConnectionStatus.disconnected;
      }
    });
  }
}
