import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

final db = Database(
  host: Platform.environment['BACKEND_HOST'] ?? 'localhost',
  database: Platform.environment['POSTGRES_DB'] ?? 'postgres',
  username: Platform.environment['POSTGRES_USER'] ?? 'postgres',
  password: Platform.environment['POSTGRES_PASSWORD'] ?? 'postgres',
  useSSL: false,
);

Handler middleware(Handler handler) {
  return handler.use(provider<Database>((_) => db));
}
