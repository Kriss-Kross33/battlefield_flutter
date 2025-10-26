import 'package:backend/repositories/player_repository.dart';
import 'package:backend/repositories/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

Handler middleware(Handler handler) {
  return (context) async {
    const sessionRepository = SessionRepository();
    final db = context.read<Database>();
    final playerRepository = PlayerRepository(db: db);
    handler
        .use(requestLogger())
        .use(provider<SessionRepository>((_) => sessionRepository))
        .use(provider<PlayerRepository>((_) => playerRepository));
    final response = handler(context);
    return response;
  };
}
