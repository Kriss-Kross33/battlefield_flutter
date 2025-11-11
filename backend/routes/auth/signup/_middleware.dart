import 'package:backend/repositories/player_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

import '../../db/postgresql/_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(provider<Database>((_) => db)).use(
    provider<BattleFieldPlayerRepository>((context) {
      final db = context.read<Database>();
      return BattleFieldPlayerRepository(db: db);
    }),
  );
}
