import 'dart:convert';
import 'dart:io';

import 'package:backend/extensions/player_view_extension.dart';
import 'package:backend/repositories/leadership_board_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _getLeadershipBoard(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getLeadershipBoard(RequestContext context) async {
  final players = await context.read<LeadershipBoardRepository>().loadFromDb();
  final data = json.encode(players.map((player) => player.toJson()).toList());
  return Response(body: data);
}
