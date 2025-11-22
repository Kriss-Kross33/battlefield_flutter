// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_check_service/internet_connection_check_service.dart';

void main() {
  group('InternetConnectionCheckService', () {
    test('can be instantiated', () {
      expect(InternetConnectionCheckService(), isNotNull);
    });
  });
}
