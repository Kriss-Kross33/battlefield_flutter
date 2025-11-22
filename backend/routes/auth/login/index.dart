import 'dart:convert';
import 'dart:io';

import 'package:backend/exceptions/custom_exceptions.dart';
import 'package:backend/repositories/player_repository.dart';
import 'package:backend/repositories/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _post(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _post(RequestContext context) async {
  try {
    final requestBody = await context.request.body();
    if (requestBody.isEmpty) {
      return Response(statusCode: HttpStatus.badRequest);
    }
    final requestFields = jsonDecode(requestBody) as Map<String, dynamic>?;

    final email = requestFields!['email'] as String?;
    final password = requestFields['password'] as String?;

    if (email == null || password == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'details': 'Email and Password fields are required'},
      );
    }
    final player = await context
        .read<BattleFieldPlayerRepository>()
        .loginPlayer(email: email, password: password);
    if (player == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'details': 'User with provided credentials does not exist'},
      );
    }
    final session = context.read<SessionRepository>();
    final createdSession =
        await session.createSessionWithRefreshToken(userId: player.id);
    final body = {
      'user_id': createdSession.userId,
      'access_token': createdSession.accessToken,
      'refresh_token': createdSession.refreshToken,
      'messsage': 'success',
      'access_token_expires_in':
          createdSession.accessTokenExpiry.toIso8601String(),
      'refresh_token_expires_in':
          createdSession.refreshTokenExpiry.toIso8601String(),
    };
    return Response.json(body: body);
  } on InvalidEmailOrPasswordException catch (e) {
    final errorResponse = json.encode({'message': e.toString()});
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: errorResponse,
    );
  }

  // final leaderboard = LeadershipBoardRepository(
  //   db: context.read<Database>(),
  // );
  // leaderboard.addPlayer('Alice');
  // leaderboard.addPlayer('Bob');
  // leaderboard.addPlayer('Charlie');

  // leaderboard.recordMatch(playerA: 'Alice', playerB: 'Bob');
  // leaderboard.recordMatch(playerA: 'Charlie', playerB: 'Bob', drawn: true);
  // leaderboard.recordMatch(playerA: 'Alice', playerB: 'Charlie');
  // leaderboard.showTop();
}
