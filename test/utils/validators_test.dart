import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_capstone/utils/validators.dart';

void main() {
  group('AppValidators Unit Tests', () {
    test('validateEmail should validate emails accurately', () {
      expect(AppValidators.validateEmail(null), 'Email address is required');
      expect(AppValidators.validateEmail(''), 'Email address is required');
      expect(AppValidators.validateEmail('   '), 'Email address is required');
      expect(AppValidators.validateEmail('plainaddress'),
          'Please enter a valid email address');
      expect(AppValidators.validateEmail('missingdomain@.com'),
          'Please enter a valid email address');
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
      expect(AppValidators.validateEmail('john.doe@company.org'), isNull);
    });

    test('validatePassword should enforce minimum length', () {
      expect(AppValidators.validatePassword(null), 'Password is required');
      expect(AppValidators.validatePassword(''), 'Password is required');
      expect(AppValidators.validatePassword('12345'),
          'Password must be at least 6 characters long');
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('StrongPassword!2026'), isNull);
    });

    test('validateConfirmPassword should match passwords accurately', () {
      expect(AppValidators.validateConfirmPassword(null, 'secret'),
          'Please confirm your password');
      expect(AppValidators.validateConfirmPassword('wrong', 'secret'),
          'Passwords do not match');
      expect(AppValidators.validateConfirmPassword('secret', 'secret'), isNull);
    });

    test('validateTaskTitle should reject empty and excessive titles', () {
      expect(AppValidators.validateTaskTitle(null), 'Task title cannot be empty');
      expect(AppValidators.validateTaskTitle(''), 'Task title cannot be empty');
      expect(AppValidators.validateTaskTitle('   '),
          'Task title cannot be empty');
      expect(AppValidators.validateTaskTitle('Valid Task Title'), isNull);

      final veryLongTitle = 'A' * 101;
      expect(AppValidators.validateTaskTitle(veryLongTitle),
          'Title must be 100 characters or less');
    });

    test('validateDisplayName should require at least 2 characters', () {
      expect(AppValidators.validateDisplayName(null), 'Display name is required');
      expect(AppValidators.validateDisplayName(''), 'Display name is required');
      expect(AppValidators.validateDisplayName('A'),
          'Name must be at least 2 characters');
      expect(AppValidators.validateDisplayName('Alex'), isNull);
    });
  });
}
