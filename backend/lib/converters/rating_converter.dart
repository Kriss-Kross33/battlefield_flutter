import 'dart:convert';

import 'package:dart_glicko2/dart_glicko2.dart';
import 'package:stormberry/stormberry.dart';

/// {@template rating_converter}
/// Convert rating to database compatible type
/// {@endtemplate}
class RatingConverter extends TypeConverter<Rating> {
  ///{@macro rating_converter}
  const RatingConverter() : super('text');

  @override
  dynamic encode(Rating value) {
    return jsonEncode(value.toJson());
  }

  @override
  Rating decode(dynamic value) {
    return Rating.fromJson(jsonDecode(value as String) as Map<String, dynamic>);
  }
}
