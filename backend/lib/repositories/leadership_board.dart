import 'dart:convert';
import 'dart:io';

import 'package:backend/exceptions/custom_exceptions.dart';
import 'package:dart_glicko2/dart_glicko2.dart';
import 'package:stormberry/stormberry.dart';

/// {@template leadership_board}
/// A class for managing the leadership board of players
/// {@endtemplate}
class LeadershipBoard {
  /// {@macro leadership_board}
  LeadershipBoard({required Database db}) : _db = db;

  /// The database to use for the leadership board
  final Database _db;

  /// The map of players and their ratings
  final Map<String, Rating> _players = {};

  /// The Glicko2 engine to use for rating players
  final Glicko2 _engine = Glicko2();

  /// Add a player to the leadership board with the given [id] and [rating]
  /// If [rating] is not provided, a new rating is created
  void addPlayer(String id, [Rating? rating]) {
    _players[id] = rating ?? _engine.createRating();
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

  List<MapEntry<String, Rating>> get sortedPlayers {
    final list = _players.entries.toList();
    list.sort((a, b) => b.value.mu.compareTo(a.value.mu));
    return list;
  }

  void showTop([int n = 10]) {
    final top = sortedPlayers.take(n);
    print('\n🏆 LEADERBOARD 🏆');
    for (var i = 0; i < top.length; i++) {
      final entry = top.elementAt(i);
      print('${i + 1}. ${entry.key}: ${entry.value.mu.toStringAsFixed(2)}');
    }
  }

  ///
  List<Map<String, dynamic>> topPlayers([int n = 10]) {
    return sortedPlayers
        .take(n)
        .map(
          (e) => {
            'id': e.key,
            'rating': e.value.mu,
            'phi': e.value.phi,
            'sigma': e.value.sigma,
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
  Future<void> loadFromDb(String path) async {
    final file = File(path);
    if (!await file.exists()) return;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    data.forEach((k, v) {
      _players[k] = Rating.fromJson(v as Map<String, dynamic>);
    });
  }
}
