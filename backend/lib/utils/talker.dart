import 'package:talker/talker.dart';

/// The talker instance for the player repository
final talker = Talker(
  settings: TalkerSettings(
    colors: {
      TalkerKey.info: AnsiPen()..magenta(),
      // YourCustomKey.logKey: AnsiPen()..green(),
    },
    titles: {
      TalkerKey.exception: 'Whatever you want',
      TalkerKey.error: 'E',
      TalkerKey.info: 'i',
      // YourCustomKey.logKey: 'Custom',
    },
  ),
);
