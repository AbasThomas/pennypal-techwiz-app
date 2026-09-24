import 'package:bootstrap_flutter/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('validates email addresses', () {
      expect(Validators.email('person@example.com'), isNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
    test('enforces password requirements', () {
      expect(Validators.password('password1'), isNull);
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('onlyletters'), isNotNull);
    });
    test('confirms matching passwords', () {
      expect(Validators.confirmPassword('password1', 'password1'), isNull);
      expect(Validators.confirmPassword('password2', 'password1'), isNotNull);
    });
  });
}
