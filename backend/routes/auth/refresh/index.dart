import 'dart:convert';
import 'dart:io';

import 'package:backend/exceptions/exceptions.dart';
import 'package:backend/repositories/session_repository.dart';
import 'package:backend/utils/utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _post(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _post(RequestContext context) async {
  final requestBody = await context.request.body();
  final requestFields = jsonDecode(requestBody) as Map<String, dynamic>?;
  final refreshToken = requestFields?['refresh_token'] as String?;
  if (refreshToken == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'details': 'Refresh token is required'},
    );
  }

  try {
    final session = context.read<SessionRepository>();
    final response = await session.refreshAccessToken(refreshToken);
    return Response.json(
      body: {
        'access_token': response.accessToken,
        'access_token_expires_in': response.expiresIn,
      },
    );
  } on SessionExpiredException catch (e) {
    talker.error(e);
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'details': e.message},
    );
  } catch (e) {
    talker.error(e);
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'details': 'An error occurred while refreshing the access token'},
    );
  }
}
