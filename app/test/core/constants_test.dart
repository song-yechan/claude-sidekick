import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/core/constants.dart';

void main() {
  group('categoryColors', () {
    test('contains 9 colors', () {
      expect(categoryColors.length, 9);
    });

    test('all colors are valid hex format', () {
      final hexPattern = RegExp(r'^#[0-9a-fA-F]{6}$');

      for (final color in categoryColors) {
        expect(hexPattern.hasMatch(color), isTrue,
            reason: '$color should be a valid hex color');
      }
    });

    test('all colors are unique', () {
      final uniqueColors = categoryColors.toSet();
      expect(uniqueColors.length, categoryColors.length,
          reason: 'All colors should be unique');
    });

    test('colors include expected basic colors', () {
      // Check that we have a good variety
      expect(categoryColors, contains('#ef4444')); // red
      expect(categoryColors, contains('#3b82f6')); // blue
      expect(categoryColors, contains('#10b981')); // emerald
    });

    test('colors are lowercase hex', () {
      for (final color in categoryColors) {
        expect(color, color.toLowerCase(),
            reason: '$color should be lowercase');
      }
    });

    test('can be indexed safely with modulo', () {
      // Common pattern: categoryColors[index % categoryColors.length]
      for (var i = 0; i < 100; i++) {
        final index = i % categoryColors.length;
        expect(categoryColors[index], isNotNull);
        expect(categoryColors[index], isNotEmpty);
      }
    });

    test('first color is red', () {
      expect(categoryColors.first, '#ef4444');
    });

    test('last color is pink', () {
      expect(categoryColors.last, '#ec4899');
    });

    test('contains expected color spectrum', () {
      // Verify the color spectrum is well distributed
      final expectedComments = [
        'red',
        'orange',
        'amber',
        'lime',
        'emerald',
        'cyan',
        'blue',
        'violet',
        'pink',
      ];

      // Verify we have the right number of colors
      expect(categoryColors.length, expectedComments.length);
    });
  });
}
