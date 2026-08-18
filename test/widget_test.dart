import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app strings have matching ar/en keys', () {
    expect(AppStrings.ar.keys.toSet(), AppStrings.en.keys.toSet());
  });
}
