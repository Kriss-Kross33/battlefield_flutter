import 'package:equatable/equatable.dart';

///{@template player_entity}
/// Represents a player
///{@endtemplate}
class PlayerEntity extends Equatable {
  /// {@macro Player}
  const PlayerEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.streak = 0,
    this.wins = 0,
    this.losses = 0,
    this.score = 0,
    this.avatarUrl,
  });

  /// convert json to Player object
  // factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  final String id;

  /// The player's user name
  final String username;

  /// The player's email
  final String email;

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

  /// The player's hashed password
  final String password;

  /// Convert player to json representation
  // Map<String, dynamic> toJson() => _$PlayerToJson(this);

  /// create an empty representation of a player to prevent dealing with
  /// null values
  // static const Player empty = Player(
  //   email: '',
  //   password: '',
  //   id: '',
  //   username: '',
  // );

  @override
  List<Object?> get props =>
      [id, username, email, avatarUrl, score, wins, losses, streak, password];
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
