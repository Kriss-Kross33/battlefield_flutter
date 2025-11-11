import 'dart:convert';

import 'package:backend/exceptions/exceptions.dart';
import 'package:backend/models/player/player.dart';
import 'package:backend/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_glicko2/dart_glicko2.dart';
import 'package:stormberry/stormberry.dart';
import 'package:uuid/uuid.dart';

/// {@template battle_field_player_repository}
///
/// {@endtemplate}
class BattleFieldPlayerRepository {
  /// {@macro battle_field_player_repository}
  const BattleFieldPlayerRepository({required Database db}) : _db = db;
  final Database _db;

  /// Login the player with the [email] and [password].
  Future<PlayerView?> loginPlayer({
    required String email,
    required String password,
  }) async {
    final hashedPassword = hashPassword(password);
    final matchingPlayers = await _db.players.queryPlayers(
      QueryParams(
        where: 'email=@email',
        values: {'email': email},
      ),
    );
    // Check if the user exists
    if (matchingPlayers.isEmpty) {
      throw const PlayerNotFoundException(message: 'Player not found');
    }

    final player = matchingPlayers.first;
    if (!verifyPassword(
      password: player.password,
      hashedPassword: hashedPassword,
    )) {
      throw const InvalidEmailOrPasswordException(
        message: 'Invalid email or password',
      );
    }
    return player;
  }

  /// Create a player account
  Future<PlayerView?> createPlayer({
    required String email,
    required String password,
    required String username,
  }) async {
    // Check if the user already exists

    final matchingPlayers = await _db.players.queryPlayers(
      QueryParams(
        where: 'email=@email',
        values: {'email': email},
      ),
    );
    if (matchingPlayers.isNotEmpty) {
      throw const PlayerAlreadyExistsException(
        message: 'Player already exists',
      );
    }
    const uuid = Uuid();
    final userId = uuid.v4();
    final hashedPassword = hashPassword(password);
    // Adds a player to the player table
    await _db.players.insertOne(
      PlayerInsertRequest(
        id: userId,
        email: email,
        password: hashedPassword,
        username: username,
        rating: const Rating(),
      ),
    );
    final user = await _db.players.queryPlayer(userId);
    return user;
  }

  /// Fetches the user from the database by [id]
  Future<PlayerView?> getPlayerById(String? id) async {
    if (id == null) {
      return null;
    }
    final player = await _db.players.queryPlayer(id);
    talker.debug('PLAYER ID: ${player?.id}');
    return player;
  }

  ///
  String hashPassword(String password) {
    /// Convert the password to bytes
    final bytes = utf8.encode(password);

    /// Create SHA-256 hash
    final digest = sha256.convert(bytes);

    /// return the hex string
    return digest.toString();
  }

  /// Verify the password against the hashed password
  bool verifyPassword({
    required String password,
    required String hashedPassword,
  }) {
    // final hashedInput = hashPassword(password);
    return password == hashedPassword;
  }
}
