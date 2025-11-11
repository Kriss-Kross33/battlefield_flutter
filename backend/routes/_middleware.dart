import 'package:backend/repositories/player_repository.dart';
import 'package:backend/repositories/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:stormberry/stormberry.dart';

import 'db/postgresql/_middleware.dart' as db;

Handler applyBaseMiddleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        provider<SessionRepository>(
          (context) => SessionRepository(
            db: context.read<Database>(),
          ),
        ),
      )
      .use(
        provider<BattleFieldPlayerRepository>(
          (context) => BattleFieldPlayerRepository(
            db: context.read<Database>(),
          ),
        ),
      )
      .use(db.middleware);
}

Handler applyAuthenticatedMiddleware(Handler handler) {
  return applyBaseMiddleware(handler).use(
    bearerAuthentication(
      authenticator: (context, token) async {
        final sessionRepository = context.read<SessionRepository>();
        final playerRepository = context.read<BattleFieldPlayerRepository>();
        final session = await sessionRepository.getSessionFromToken(token);
        if (session == null) {
          return null;
        }
        return playerRepository.getPlayerById(session.userId);
      },
    ),
  );
}

Handler middleware(Handler handler) => applyBaseMiddleware(handler);
