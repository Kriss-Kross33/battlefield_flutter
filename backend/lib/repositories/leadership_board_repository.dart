import 'dart:convert';
import 'dart:io';

import 'package:backend/exceptions/custom_exceptions.dart';
import 'package:backend/models/player/player.dart';
import 'package:dart_glicko2/dart_glicko2.dart';
import 'package:stormberry/stormberry.dart';

/// {@template leadership_board}
/// A class for managing the leadership board of players
/// {@endtemplate}
class LeadershipBoardRepository {
  /// {@macro leadership_board}
  LeadershipBoardRepository({required Database db}) : _db = db;

  /// The database to use for the leadership board
  final Database _db;

  /// The map of players and their ratings
  final Map<String, Rating> _players = {};

  /// The Glicko2 engine to use for rating players
  final Glicko2 _engine = Glicko2();

  /// Add a player to the leadership board with the given [id] and [rating]
  /// If [rating] is not provided, a new rating is created
  // void addPlayer(String id, [Rating? rating]) {
  //   _players[id] = rating ?? _engine.createRating();
  // }

  /// Add a player to the leadership board with the given [id] and [rating]
  /// If [rating] is not provided, a new rating is created
  Future<void> addPlayer(String id, [Rating? rating]) async {
    try {
      final playerRating = rating ?? _engine.createRating();
      await _db.players
          .updateOne(PlayerUpdateRequest(id: id, rating: playerRating));
    } on PlayerNotFoundException {
      rethrow;
    } catch (e) {
      throw UnkownException(message: e.toString());
    }
  }

  ///
  void recordMatch({
    required String playerA,
    required String playerB,
    bool drawn = false,
  }) {
    if (!_players.containsKey(playerA) || !_players.containsKey(playerB)) {
      throw const PlayerNotFoundException(
        message: 'One or both players are not found on the leadership board',
      );
    }
    final (updatedA, updatedB) = _engine.rate1v1(
      playerA: _players[playerA]!,
      playerB: _players[playerB]!,
      drawn: drawn,
    );

    _players[playerA] = updatedA;
    _players[playerB] = updatedB;
  }

  Map<String, Rating> get players => _players;

  // List<MapEntry<String, Rating>> get sortedPlayers {
  //   final list = _players.entries.toList();
  //   list.sort((a, b) => b.value.mu.compareTo(a.value.mu));
  //   return list;
  // }

  /// Sort the list of players according to their ratings
  Future<List<PlayerView>> get sortedPlayers async {
    final players = await _db.players.queryPlayers();
    players.sort((a, b) => b.rating!.mu.compareTo(a.rating!.mu));
    return players;
  }

  /// Display the top [n] rated players
  Future<void> showTop([int n = 10]) async {
    final players = await sortedPlayers;
    final top = players.take(n).toList();
    print('\n🏆 LEADERBOARD 🏆');
    for (var i = 0; i < top.length; i++) {
      final entry = top.elementAt(i);
      print(
        '${i + 1}. ${entry.username}: ${entry.rating!.mu.toStringAsFixed(2)}',
      );
    }
  }

  ///
  Future<List<Map<String, dynamic>>> topPlayers([int n = 10]) async {
    final players = await sortedPlayers;
    return players
        .take(n)
        .map(
          (player) => {
            'id': player.id,
            'rating': player.rating?.toJson(),
            'phi': player.rating?.phi,
            'sigma': player.rating?.sigma,
          },
        )
        .toList();
  }

  ///
  Future<void> saveToDatabase(String path) async {
    final file = File(path);
    final jsonData =
        jsonEncode(_players.map((k, v) => MapEntry(k, v.toJson())));
    await file.writeAsString(jsonData);
  }

  ///
  Future<List<PlayerView>> loadFromDb() async {
    return sortedPlayers;
  }
}
