import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()

///{@template Player}
/// Represents a player
///{@endtemplate}
class Player {
  /// {@macro Player}
  const Player({
    required this.id,
    required this.username,
    this.streak = 0,
    this.wins = 0,
    this.losses = 0,
    this.score = 0,
    this.avatarUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// The unique identifier of the player
  final String id;

  /// The player's user name
  final String username;

  /// The display image set by the player
  final String? avatarUrl;

  /// The player's total score
  final int score;

  /// The number of times the player has won a game
  final int wins;

  /// The number of times the player has lost a match
  final int losses;

  /// The player's winning streak
  final int streak;

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

/**
 * 
 * Player model
 * String? id
 * String? name
 * Score score
 * 
 * 
 * LeadershipBoard
 * 
 * 
 * Score
 * int wins
 * int losses
 * int winstreak
 * int quits
 * int totalScore
 * 
 */
