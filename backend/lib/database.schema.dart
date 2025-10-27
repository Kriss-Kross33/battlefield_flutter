// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint
// dart format off

import 'package:stormberry/migrate.dart';

final DatabaseSchema schema = DatabaseSchema.fromMap({
  "players": {
    "columns": {
      "id": {
        "type": "text"
      },
      "username": {
        "type": "text"
      },
      "email": {
        "type": "text"
      },
      "avatar_url": {
        "type": "text",
        "isNullable": true
      },
      "score": {
        "type": "int8",
        "default": "0"
      },
      "wins": {
        "type": "int8",
        "default": "0"
      },
      "losses": {
        "type": "int8",
        "default": "0"
      },
      "streak": {
        "type": "int8",
        "default": "0"
      },
      "password": {
        "type": "text",
        "default": "0"
      }
    },
    "constraints": [
      {
        "type": "primary_key",
        "column": "id"
      }
    ],
    "indexes": []
  },
  "player_sessions": {
    "columns": {
      "id": {
        "type": "text"
      },
      "token": {
        "type": "text"
      },
      "refresh_token": {
        "type": "text",
        "isNullable": true
      },
      "user_id": {
        "type": "text"
      },
      "expiry_date": {
        "type": "timestamp"
      },
      "refresh_expiry": {
        "type": "timestamp",
        "isNullable": true
      },
      "created_at": {
        "type": "timestamp"
      },
      "last_refreshed_at": {
        "type": "timestamp",
        "isNullable": true
      }
    },
    "constraints": [
      {
        "type": "primary_key",
        "column": "id"
      }
    ],
    "indexes": []
  }
});
