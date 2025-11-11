import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backend/exceptions/exceptions.dart';
import 'package:backend/models/auth/refresh_token_response.dart';
import 'package:backend/models/auth/session_response.dart';
import 'package:backend/models/player_session.dart/session.dart';
import 'package:backend/utils/utils.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:stormberry/stormberry.dart';
import 'package:uuid/uuid.dart';

/// {@template session_repository}
/// Repository which manages sessions.
/// {@endtemplate}
class SessionRepository {
  /// {@macro session_repository}
  ///
  /// The [now] function is used to get the current date and time.
  SessionRepository({
    required Database db,
    DateTime Function()? now,
  })  : _db = db,
        _now = now ?? DateTime.now;

  final Database _db;
  final DateTime Function() _now;

  /// Creates a new session for the user with the given [userId]
  Future<PlayerSessionView> createSession({required String userId}) async {
    final now = _now();
    const uuid = Uuid();

    try {
      // Generate JWT token
      final jwt = JWT(
        {'id': userId},
        issuer: 'battlefield-game',
      );
      final key = Platform.environment['SECRET_PARAPHRASE'];
      if (key == null) {
        throw JWTException('Invalid SECRET_PARAPHRASE Key');
      }
      final token = jwt.sign(SecretKey(key));

      // Create session record in database
      final sessionId = uuid.v4();
      final expiryDate = now.add(const Duration(days: 1));

      // Insert session into database
      await _db.playerSessions.insertOne(
        PlayerSessionInsertRequest(
          id: sessionId,
          token: token,
          userId: userId,
          expiryDate: expiryDate,
          createdAt: now,
        ),
      );

      // Return the created session view
      final session = await _db.playerSessions.queryPlayerSession(sessionId);
      if (session == null) {
        throw Exception('Failed to create session');
      }

      return session;
    } on JWTException catch (e) {
      talker.error(e);
      rethrow;
    } catch (e) {
      talker.error(e);
      rethrow;
    }
  }

  /// Get a session by its token
  Future<PlayerSessionView?> getSessionByToken(String token) async {
    final sessions = await _db.playerSessions.queryPlayerSessions(
      QueryParams(
        where: 'token=@token',
        values: {'token': token},
      ),
    );

    if (sessions.isEmpty) return null;

    final session = sessions.first;

    // Check if session has expired
    if (session.expiryDate.isBefore(_now())) {
      return null;
    }

    return session;
  }

  /// Delete a session by its token
  Future<void> deleteSession(String token) async {
    final session = await getSessionByToken(token);
    if (session != null) {
      await _db.playerSessions.deleteOne(session.id);
    }
  }

  /// Delete expired sessions (cleanup method)
  Future<void> deleteExpiredSessions() async {
    final now = _now();
    final expiredSessions = await _db.playerSessions.queryPlayerSessions(
      QueryParams(
        where: 'expiry_date < @now',
        values: {'now': now},
      ),
    );

    for (final session in expiredSessions) {
      await _db.playerSessions.deleteOne(session.id);
    }
  }

  /// Queries the DB and returns a session by [token]
  ///
  /// if the is no session returned from the db or the session has
  /// expired the method returns `null`.
  Future<PlayerSessionView?> getSessionFromToken(String token) async {
    final sessions = await _db.playerSessions.queryPlayerSessions(
      QueryParams(
        where: 'token=@token',
        values: {'token': token},
      ),
    );
    if (sessions.isEmpty || sessions.first.expiryDate.isAfter(_now())) {
      return null;
    }
    return sessions.first;
  }

  /// Verify the token
  void verifyToken(String token) {
    try {
      final key = Platform.environment['SECRET_PARAPHRASE'];
      if (key == null) {
        throw JWTException('Invalid SECRET_PARAPHRASE Key');
      }
      final jwt = JWT.verify(token, SecretKey(key));
      talker.debug('Payload: ${jwt.payload}');
    } on JWTExpiredException catch (e) {
      talker.error(e);
    } on JWTException catch (e) {
      talker.error(e);
    }
  }

  /// Generate a refresh token using a JWT
  String _generateRefreshToken(String userId) {
    final jwt = JWT(
      {
        'id': userId,
        'type': 'refresh',
      },
      issuer: 'battlefield-game',
    );
    final key = Platform.environment['SECRET_PARAPHRASE'];
    if (key == null) {
      throw JWTException('Invalid SECRET_PARAPHRASE Key');
    }
    return jwt.sign(SecretKey(key), expiresIn: const Duration(days: 7));
  }

  /// Generate a refresh token using a random string
  // ignore: unused_element
  String _generateRefreshToken2() {
    final randomBytes =
        List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64Url.encode(randomBytes);
  }

  /// Create a session with a refresh token
  Future<SessionResponse> createSessionWithRefreshToken({
    required String userId,
  }) async {
    final now = _now();
    const uuid = Uuid();

    // Generate the Access token (JWT, 15 mins)
    final accessToken = _generateAccessToken(userId);

    // Generate Refresh token (random string, 7 days)
    final refreshToken = _generateRefreshToken(userId);

    // Calculate the expiry dates
    final accessTokenExpiry = now.add(const Duration(minutes: 2));
    final refreshExpiry = now.add(const Duration(minutes: 5));

    // Save the session in the database
    final sessionId = uuid.v4();
    await _db.playerSessions.insertOne(
      PlayerSessionInsertRequest(
        id: sessionId,
        token: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        expiryDate: accessTokenExpiry,
        refreshExpiry: refreshExpiry,
        createdAt: now,
      ),
    );

    // Return the session response
    return SessionResponse(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshExpiry,
    );
  }

  /// Create JWT access token
  String _generateAccessToken(String userId) {
    try {
      final jwt = JWT(
        {
          'id': userId,
          'type': 'access',
        },
        issuer: 'battlefield-game',
      );
      final key = Platform.environment['SECRET_PARAPHRASE'];
      if (key == null) {
        throw JWTException('Invalid SECRET_PARAPHRASE Key');
      }
      return jwt.sign(SecretKey(key), expiresIn: const Duration(minutes: 2));
    } on JWTException catch (e) {
      talker.error(e);
      rethrow;
    } on Exception catch (e) {
      talker.error(e);
      rethrow;
    }
  }

  /// Refresh the access token using the refresh token
  Future<RefreshTokenResponse> refreshAccessToken(String refreshToken) async {
    final now = _now();

    // Find the session by the refresh token
    final sessions = await _db.playerSessions.queryPlayerSessions(
      QueryParams(
        where: 'refresh_token=@token',
        values: {'token': refreshToken},
      ),
    );
    if (sessions.isEmpty) {
      throw const SessionNotFoundException(message: 'Invalid refresh token');
    }
    final session = sessions.first;
    // Check refresh tojen expiry
    if (session.refreshExpiry!.isBefore(now)) {
      throw const SessionExpiredException(message: 'Refresh token expired');
    }

    // Generate a new access token
    final newAccessToken = _generateAccessToken(session.userId);
    final newAccessTokenExpiry = now.add(const Duration(minutes: 2));

    // Update the session in the db
    await _db.playerSessions.updateOne(
      PlayerSessionUpdateRequest(
        id: session.id,
        token: newAccessToken,
        expiryDate: newAccessTokenExpiry,
        lastRefreshedAt: now,
      ),
    );
    return RefreshTokenResponse(
      accessToken: newAccessToken,
      expiresIn: 120,
    );
  }

  /// Logout the user and delete the session by the refresh token
  Future<void> logout(String refreshToken) async {
    final sessions = await _db.playerSessions.queryPlayerSessions(
      QueryParams(
        where: 'refresh_token=@token',
        values: {'token': refreshToken},
      ),
    );
    if (sessions.isNotEmpty) {
      await _db.playerSessions.deleteOne(sessions.first.id);
    }
  }
}
