// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint
// ignore_for_file: annotate_overrides
// dart format off

part of 'player.dart';

extension PlayerRepositories on Session {
  PlayerRepository get players => PlayerRepository._(this);
}

abstract class PlayerRepository
    implements
        ModelRepository,
        ModelRepositoryInsert<PlayerInsertRequest>,
        ModelRepositoryUpdate<PlayerUpdateRequest>,
        ModelRepositoryDelete<String> {
  factory PlayerRepository._(Session db) = _PlayerRepository;

  Future<PlayerView?> queryPlayer(String id);
  Future<List<PlayerView>> queryPlayers([QueryParams? params]);
}

class _PlayerRepository extends BaseRepository
    with
        RepositoryInsertMixin<PlayerInsertRequest>,
        RepositoryUpdateMixin<PlayerUpdateRequest>,
        RepositoryDeleteMixin<String>
    implements PlayerRepository {
  _PlayerRepository(super.db) : super(tableName: 'players', keyName: 'id');

  @override
  Future<PlayerView?> queryPlayer(String id) {
    return queryOne(id, PlayerViewQueryable());
  }

  @override
  Future<List<PlayerView>> queryPlayers([QueryParams? params]) {
    return queryMany(PlayerViewQueryable(), params);
  }

  @override
  Future<void> insert(List<PlayerInsertRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.execute(
      Sql.named(
        'INSERT INTO "players" ( "id", "username", "email", "avatar_url", "score", "wins", "losses", "streak", "password" )\n'
        'VALUES ${requests.map((r) => '( ${values.add(r.id)}:text, ${values.add(r.username)}:text, ${values.add(r.email)}:text, ${values.add(r.avatarUrl)}:text, ${r.score != null ? '${values.add(r.score)}:int8' : 'DEFAULT'}, ${r.wins != null ? '${values.add(r.wins)}:int8' : 'DEFAULT'}, ${r.losses != null ? '${values.add(r.losses)}:int8' : 'DEFAULT'}, ${r.streak != null ? '${values.add(r.streak)}:int8' : 'DEFAULT'}, ${r.password != null ? '${values.add(r.password)}:text' : 'DEFAULT'} )').join(', ')}\n',
      ),
      parameters: values.values,
    );
  }

  @override
  Future<void> update(List<PlayerUpdateRequest> requests) async {
    if (requests.isEmpty) return;

    final updateRequests = [
      for (final r in requests)
        if (r.username != null ||
            r.email != null ||
            r.avatarUrl != null ||
            r.score != null ||
            r.wins != null ||
            r.losses != null ||
            r.streak != null ||
            r.password != null)
          r,
    ];

    if (updateRequests.isNotEmpty) {
      var values = QueryValues();
      await db.execute(
        Sql.named(
          'UPDATE "players"\n'
          'SET "username" = COALESCE(UPDATED."username", "players"."username"), "email" = COALESCE(UPDATED."email", "players"."email"), "avatar_url" = COALESCE(UPDATED."avatar_url", "players"."avatar_url"), "score" = COALESCE(UPDATED."score", "players"."score"), "wins" = COALESCE(UPDATED."wins", "players"."wins"), "losses" = COALESCE(UPDATED."losses", "players"."losses"), "streak" = COALESCE(UPDATED."streak", "players"."streak"), "password" = COALESCE(UPDATED."password", "players"."password")\n'
          'FROM ( VALUES ${updateRequests.map((r) => '( ${values.add(r.id)}:text::text, ${values.add(r.username)}:text::text, ${values.add(r.email)}:text::text, ${values.add(r.avatarUrl)}:text::text, ${values.add(r.score)}:int8::int8, ${values.add(r.wins)}:int8::int8, ${values.add(r.losses)}:int8::int8, ${values.add(r.streak)}:int8::int8, ${values.add(r.password)}:text::text )').join(', ')} )\n'
          'AS UPDATED("id", "username", "email", "avatar_url", "score", "wins", "losses", "streak", "password")\n'
          'WHERE "players"."id" = UPDATED."id"',
        ),
        parameters: values.values,
      );
    }
  }
}

class PlayerInsertRequest {
  PlayerInsertRequest({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.score,
    this.wins,
    this.losses,
    this.streak,
    this.password,
  });

  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int? score;
  final int? wins;
  final int? losses;
  final int? streak;
  final String? password;
}

class PlayerUpdateRequest {
  PlayerUpdateRequest({
    required this.id,
    this.username,
    this.email,
    this.avatarUrl,
    this.score,
    this.wins,
    this.losses,
    this.streak,
    this.password,
  });

  final String id;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final int? score;
  final int? wins;
  final int? losses;
  final int? streak;
  final String? password;
}

class PlayerViewQueryable extends KeyedViewQueryable<PlayerView, String> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(String key) => TextEncoder.i.encode(key);

  @override
  String get query =>
      'SELECT "players".*'
      'FROM "players"';

  @override
  String get tableAlias => 'players';

  @override
  PlayerView decode(TypedMap map) => PlayerView(
    id: map.get('id'),
    username: map.get('username'),
    email: map.get('email'),
    avatarUrl: map.getOpt('avatar_url'),
    score: map.get('score'),
    wins: map.get('wins'),
    losses: map.get('losses'),
    streak: map.get('streak'),
    password: map.get('password'),
  );
}

class PlayerView {
  PlayerView({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.score,
    required this.wins,
    required this.losses,
    required this.streak,
    required this.password,
  });

  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int score;
  final int wins;
  final int losses;
  final int streak;
  final String password;
}
