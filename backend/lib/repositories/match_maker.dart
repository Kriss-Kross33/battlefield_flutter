import 'package:backend/repositories/leadership_board.dart';

/// {@template match_maker}
/// A class for finding opponents for a player based on their rating
/// {@endtemplate}
class MatchMaker {
  /// {@macro match_maker}
  MatchMaker({required this.leadershipBoard, this.maxRD = 100.0});

  /// The leadership board to use for finding opponents
  final LeadershipBoard leadershipBoard;

  /// The maximum allowed rating deviation difference
  final double maxRD; // optional: maximum allowed rating deviation difference

  /// Find an opponent for the player with the given [playerId]
  /// Returns the ID of the opponent if found, otherwise null
  String? findOpponent(String playerId) {
    final player = leadershipBoard.players[playerId];
    if (player == null) return null;
    final others = leadershipBoard.players.entries
        .where((e) => e.key != playerId)
        .toList();
    if (others.isEmpty) {
      print('No more players in the db');
      return null;
    }
    others.sort(
      (a, b) => (a.value.mu - player.mu)
          .abs()
          .compareTo(b.value.mu - player.mu)
          .abs(),
    );
    // Optionally ensure RD difference isn't too high.
    final best = others.firstWhere(
      (e) => (e.value.phi - player.phi).abs() <= maxRD,
      orElse: () => others.first,
    );
    return best.key;
  }
}
