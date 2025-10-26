import 'package:backend/repositories/player_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

import 'db/postgresql/_middleware.dart' as db;

Handler middleware(Handler handler) {
  return handler.use(db.middleware).use(
    provider<PlayerRepository>(
      (context) {
        final db = context.read<Database>();
        return PlayerRepository(db: db);
      },
    ),
  );
}
