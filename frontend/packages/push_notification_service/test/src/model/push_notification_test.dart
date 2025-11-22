import 'package:flutter_test/flutter_test.dart';
import 'package:push_notification_service/push_notification_service.dart';

void main() {
  group('PushNotification', () {
    testWidgets('can be (de)serialized', (tester) async {
      final pushNotification = PushNotification(
        title: 'test',
        body: 'test-body',
        payload: Payload(
          id: 'id',
        ),
      );

      expect(
        PushNotification.fromJson(pushNotification.toJson()),
        pushNotification,
      );
    });
  });
}
