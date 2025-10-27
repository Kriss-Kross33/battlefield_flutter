// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint
// ignore_for_file: annotate_overrides
// dart format off

part of 'session.dart';

extension SessionRepositories on Session {
  PlayerSessionRepository get playerSessions => PlayerSessionRepository._(this);
}

abstract class PlayerSessionRepository
    implements
        ModelRepository,
        ModelRepositoryInsert<PlayerSessionInsertRequest>,
        ModelRepositoryUpdate<PlayerSessionUpdateRequest>,
        ModelRepositoryDelete<String> {
  factory PlayerSessionRepository._(Session db) = _PlayerSessionRepository;

  Future<PlayerSessionView?> queryPlayerSession(String id);
  Future<List<PlayerSessionView>> queryPlayerSessions([QueryParams? params]);
}

class _PlayerSessionRepository extends BaseRepository
    with
        RepositoryInsertMixin<PlayerSessionInsertRequest>,
        RepositoryUpdateMixin<PlayerSessionUpdateRequest>,
        RepositoryDeleteMixin<String>
    implements PlayerSessionRepository {
  _PlayerSessionRepository(super.db)
    : super(tableName: 'player_sessions', keyName: 'id');

  @override
  Future<PlayerSessionView?> queryPlayerSession(String id) {
    return queryOne(id, PlayerSessionViewQueryable());
  }

  @override
  Future<List<PlayerSessionView>> queryPlayerSessions([QueryParams? params]) {
    return queryMany(PlayerSessionViewQueryable(), params);
  }

  @override
  Future<void> insert(List<PlayerSessionInsertRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.execute(
      Sql.named(
        'INSERT INTO "player_sessions" ( "id", "token", "refresh_token", "user_id", "expiry_date", "refresh_expiry", "created_at", "last_refreshed_at" )\n'
        'VALUES ${requests.map((r) => '( ${values.add(r.id)}:text, ${values.add(r.token)}:text, ${values.add(r.refreshToken)}:text, ${values.add(r.userId)}:text, ${values.add(r.expiryDate)}:timestamp, ${values.add(r.refreshExpiry)}:timestamp, ${values.add(r.createdAt)}:timestamp, ${values.add(r.lastRefreshedAt)}:timestamp )').join(', ')}\n',
      ),
      parameters: values.values,
    );
  }

  @override
  Future<void> update(List<PlayerSessionUpdateRequest> requests) async {
    if (requests.isEmpty) return;

    final updateRequests = [
      for (final r in requests)
        if (r.token != null ||
            r.refreshToken != null ||
            r.userId != null ||
            r.expiryDate != null ||
            r.refreshExpiry != null ||
            r.createdAt != null ||
            r.lastRefreshedAt != null)
          r,
    ];

    if (updateRequests.isNotEmpty) {
      var values = QueryValues();
      await db.execute(
        Sql.named(
          'UPDATE "player_sessions"\n'
          'SET "token" = COALESCE(UPDATED."token", "player_sessions"."token"), "refresh_token" = COALESCE(UPDATED."refresh_token", "player_sessions"."refresh_token"), "user_id" = COALESCE(UPDATED."user_id", "player_sessions"."user_id"), "expiry_date" = COALESCE(UPDATED."expiry_date", "player_sessions"."expiry_date"), "refresh_expiry" = COALESCE(UPDATED."refresh_expiry", "player_sessions"."refresh_expiry"), "created_at" = COALESCE(UPDATED."created_at", "player_sessions"."created_at"), "last_refreshed_at" = COALESCE(UPDATED."last_refreshed_at", "player_sessions"."last_refreshed_at")\n'
          'FROM ( VALUES ${updateRequests.map((r) => '( ${values.add(r.id)}:text::text, ${values.add(r.token)}:text::text, ${values.add(r.refreshToken)}:text::text, ${values.add(r.userId)}:text::text, ${values.add(r.expiryDate)}:timestamp::timestamp, ${values.add(r.refreshExpiry)}:timestamp::timestamp, ${values.add(r.createdAt)}:timestamp::timestamp, ${values.add(r.lastRefreshedAt)}:timestamp::timestamp )').join(', ')} )\n'
          'AS UPDATED("id", "token", "refresh_token", "user_id", "expiry_date", "refresh_expiry", "created_at", "last_refreshed_at")\n'
          'WHERE "player_sessions"."id" = UPDATED."id"',
        ),
        parameters: values.values,
      );
    }
  }
}

class PlayerSessionInsertRequest {
  PlayerSessionInsertRequest({
    required this.id,
    required this.token,
    this.refreshToken,
    required this.userId,
    required this.expiryDate,
    this.refreshExpiry,
    required this.createdAt,
    this.lastRefreshedAt,
  });

  final String id;
  final String token;
  final String? refreshToken;
  final String userId;
  final DateTime expiryDate;
  final DateTime? refreshExpiry;
  final DateTime createdAt;
  final DateTime? lastRefreshedAt;
}

class PlayerSessionUpdateRequest {
  PlayerSessionUpdateRequest({
    required this.id,
    this.token,
    this.refreshToken,
    this.userId,
    this.expiryDate,
    this.refreshExpiry,
    this.createdAt,
    this.lastRefreshedAt,
  });

  final String id;
  final String? token;
  final String? refreshToken;
  final String? userId;
  final DateTime? expiryDate;
  final DateTime? refreshExpiry;
  final DateTime? createdAt;
  final DateTime? lastRefreshedAt;
}

class PlayerSessionViewQueryable
    extends KeyedViewQueryable<PlayerSessionView, String> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(String key) => TextEncoder.i.encode(key);

  @override
  String get query =>
      'SELECT "player_sessions".*'
      'FROM "player_sessions"';

  @override
  String get tableAlias => 'player_sessions';

  @override
  PlayerSessionView decode(TypedMap map) => PlayerSessionView(
    id: map.get('id'),
    token: map.get('token'),
    refreshToken: map.getOpt('refresh_token'),
    userId: map.get('user_id'),
    expiryDate: map.get('expiry_date'),
    refreshExpiry: map.getOpt('refresh_expiry'),
    createdAt: map.get('created_at'),
    lastRefreshedAt: map.getOpt('last_refreshed_at'),
  );
}

class PlayerSessionView {
  PlayerSessionView({
    required this.id,
    required this.token,
    this.refreshToken,
    required this.userId,
    required this.expiryDate,
    this.refreshExpiry,
    required this.createdAt,
    this.lastRefreshedAt,
  });

  final String id;
  final String token;
  final String? refreshToken;
  final String userId;
  final DateTime expiryDate;
  final DateTime? refreshExpiry;
  final DateTime createdAt;
  final DateTime? lastRefreshedAt;
}
