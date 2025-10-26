import 'dart:io';

import 'package:backend/models/player_session.dart/session.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

// IN MEMORY CACHE
Map<String, PlayerSession> sessionDb = {};

/// {@template session_repository}
/// Repository which manages sessions.
/// {@endtemplate}
class SessionRepository {
  /// {@macro session_repository}
  ///
  /// The [now] function is used to get the current date and time.
  const SessionRepository({
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Creates a new session for the user with the given [userId]
  Future<PlayerSession> createSession({required String userId}) async {
    final now = _now();
    final jwt = JWT(
      {'id': userId},
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );
    final key =
        Platform.environment['SECRET_PARAPHRASE'] ?? 'SECRET_PARAPHRASE';
    final token = jwt.sign(SecretKey(key));
    print(token);
    final session = PlayerSession(
      token: token,
      userId: userId,
      expiryDate: now.add(const Duration(days: 1)),
      createdAt: now,
    );
    sessionDb[session.token] = session;
    return session;
  }
}
