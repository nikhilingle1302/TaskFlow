import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email rejects empty input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('email rejects invalid format', () {
      expect(Validators.email('not-an-email'), 'Enter a valid email address');
    });

    test('email accepts valid input', () {
      expect(Validators.email('ava@test.com'), isNull);
    });

    test('password requires at least 8 characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('Password123!'), isNull);
    });

    test('name requires at least 2 characters', () {
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('Ava'), isNull);
    });
  });
}
