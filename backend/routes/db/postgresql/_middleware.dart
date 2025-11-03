import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

final db = Database(
  host: Platform.environment['DB_HOST_ADDRESS'],
  database: Platform.environment['DB_NAME'],
  username: Platform.environment['DB_USERNAME'],
  password: Platform.environment['DB_PASSWORD'],
  useSSL: false,
);

Handler middleware(Handler handler) {
  return handler.use(provider<Database>((_) => db));
}
