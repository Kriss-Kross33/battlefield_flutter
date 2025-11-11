import 'package:backend/repositories/leadership_board_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

import '../../_middleware.dart';

Handler middleware(Handler handler) =>
    applyAuthenticatedMiddleware(handler).use(
      provider<LeadershipBoardRepository>(
        (context) => LeadershipBoardRepository(
          db: context.read<Database>(),
        ),
      ),
    );

// Handler middleware(Handler handler) {
//   return handler
//       .use(db.middleware)
//       .use(
//         bearerAuthentication<PlayerView>(
//           authenticator: (context, token) async {
//             talker.debug('WE ARE INSIDE');
//             final sessionRepository = context.read<SessionRepository>();
//             final playerRepository =
//                 context.read<BattleFieldPlayerRepository>();
//             final session = await sessionRepository.getSessionFromToken(token);
//             // talker.debug('THE SESSION USER ID ${session?.userId}');
//             final player =
//                 await playerRepository.getPlayerById(session?.userId);
//             if (player != null) {
//               return session != null ? player : null;
//             }
//             return null;
//           },
//         ),
//       )
//       .use(requestLogger())
//       .use(
//         provider<LeadershipBoardRepository>(
//           (context) {
//             final db = context.read<Database>();
//             return LeadershipBoardRepository(db: db);
//           },
//         ),
//       )
//       .use(
//         provider<BattleFieldPlayerRepository>((context) {
//           final db = context.read<Database>();
//           return BattleFieldPlayerRepository(db: db);
//         }),
//       )
//       .use(
//         provider<SessionRepository>(
//           (context) {
//             final db = context.read<Database>();
//             return SessionRepository(db: db);
//           },
//         ),
//       );
// }
