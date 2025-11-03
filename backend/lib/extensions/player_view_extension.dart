import 'package:backend/models/player/player.dart';

/// {@template player_view_json}
/// Extension to convert a PlayerView to a JSON object.
/// {@endtemplate}
extension PlayerViewJson on PlayerView {
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'score': score,
      'wins': wins,
      'losses': losses,
      'streak': streak,
    };
  }
}
