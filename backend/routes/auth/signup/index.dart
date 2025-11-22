import 'dart:convert';
import 'dart:io';

import 'package:backend/extensions/extensions.dart';
import 'package:backend/repositories/player_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _post(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _post(RequestContext context) async {
  final requestBody = await context.request.body();
  if (requestBody.isEmpty) {
    return Response(statusCode: HttpStatus.badRequest);
  }
  final requestFields = jsonDecode(requestBody) as Map<String, dynamic>?;
  final requiredFields = ['email', 'username', 'password'];
  if (requestFields == null || requestFields.isEmpty) {
    return Response(statusCode: HttpStatus.badRequest);
  }
  for (final key in requestFields.keys) {
    if (requiredFields.contains(key)) {
      requiredFields.remove(key);
    }
  }
  if (requiredFields.isNotEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'details': requiredFields.map((key) => '$key is requiured').toList(),
      },
    );
  } else {
    try {
      final playerRepository = context.read<BattleFieldPlayerRepository>();
      final email = requestFields['email'] as String;
      final password = requestFields['password'] as String;
      final username = requestFields['username'] as String;
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return Response(statusCode: HttpStatus.badRequest);
      }
      final player = await playerRepository.createPlayer(
        email: email,
        password: password,
        username: username,
      );

      return Response.json(body: player?.toJson());
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'details': e.toString(),
        },
      );
    }
  }
}
