import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final connection = await Connection.open(
      Endpoint(
        host: Platform.environment['BACKEND_HOST'] ?? 'localhost',
        database: Platform.environment['POSTGRES_DB'] ?? 'postgres',
        username: Platform.environment['POSTGRES_USER'] ?? 'postgres',
        password: Platform.environment['POSTGRES_PASSWORD'] ?? 'postgres',
      ),
    );
    final response =
        handler.use(provider<Connection>((_) => connection)).call(context);
    await connection.close();
    return response;
  };
}
