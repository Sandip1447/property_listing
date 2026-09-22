import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';

void main() {
  group('Result', () {
    test('success exposes value equality', () {
      expect(const Success<int>(42), const Success<int>(42));
    });

    test('failure result exposes its typed failure', () {
      const Failure failure = StorageFailure('Unable to persist value');

      expect(
        const FailureResult<int>(failure),
        const FailureResult<int>(failure),
      );
    });

    test('different failure types are not equal', () {
      expect(
        const StorageFailure('Failure'),
        isNot(const UnknownFailure('Failure')),
      );
    });
  });
}
