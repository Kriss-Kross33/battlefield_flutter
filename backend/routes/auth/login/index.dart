import 'dart:convert';
import 'dart:io';

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
  final requestBody = await context.request.body();
  if (requestBody.isEmpty) {
    return Response(statusCode: HttpStatus.badRequest);
  }
  final requestFields = jsonDecode(requestBody) as Map<String, dynamic>?;

  final playerRepository = context.read<PlayerRepository>();

  final email = requestFields!['email'] as String?;
  final password = requestFields['password'] as String?;

  if (email == null || password == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'details': 'Email and Password fields are required'},
    );
  }
  final player =
      await playerRepository.loginPlayer(email: email, password: password);
  if (player == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'details': 'Email and Password fields are required'},
    );
  }
  final session = context.read<SessionRepository>();
  final createdSession = await session.createSession(userId: player.id);
  final body = {
    'access_token': createdSession.token,
    'messsage': 'success',
  };
  return Future.value(Response.json(body: body));
}
