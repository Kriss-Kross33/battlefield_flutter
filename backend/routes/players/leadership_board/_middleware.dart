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
