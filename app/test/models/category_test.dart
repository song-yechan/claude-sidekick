import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/category.dart';

void main() {
  group('Category', () {
    test('fromJson creates Category correctly', () {
      final json = {
        'id': 'cat-123',
        'name': '소설',
        'color': '#FF5733',
        'created_at': '2024-01-20T10:30:00Z',
      };

      final category = Category.fromJson(json);

      expect(category.id, 'cat-123');
      expect(category.name, '소설');
      expect(category.color, '#FF5733');
      expect(category.createdAt, DateTime.parse('2024-01-20T10:30:00Z'));
    });

    test('toJson returns correct map', () {
      final category = Category(
        id: 'cat-123',
        name: '소설',
        color: '#FF5733',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final json = category.toJson();

      expect(json['name'], '소설');
      expect(json['color'], '#FF5733');
      // id와 created_at은 toJson에 포함되지 않음
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });

    test('colorValue converts hex string to Color', () {
      final category = Category(
        id: 'cat-123',
        name: '테스트',
        color: '#FF5733',
        createdAt: DateTime.now(),
      );

      final color = category.colorValue;

      expect(color, const Color(0xFFFF5733));
    });

    test('colorValue handles color without hash', () {
      final category = Category(
        id: 'cat-123',
        name: '테스트',
        color: 'FF5733',
        createdAt: DateTime.now(),
      );

      final color = category.colorValue;

      expect(color, const Color(0xFFFF5733));
    });

    test('copyWith creates new Category with updated fields', () {
      final category = Category(
        id: 'cat-123',
        name: '원본 이름',
        color: '#FF5733',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final updatedCategory = category.copyWith(
        name: '수정된 이름',
        color: '#3182F6',
      );

      expect(updatedCategory.id, 'cat-123');
      expect(updatedCategory.name, '수정된 이름');
      expect(updatedCategory.color, '#3182F6');
      expect(updatedCategory.createdAt, DateTime.parse('2024-01-20T10:30:00Z'));
    });

    test('copyWith preserves original values when not specified', () {
      final category = Category(
        id: 'cat-123',
        name: '원본 이름',
        color: '#FF5733',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final updatedCategory = category.copyWith(name: '수정된 이름');

      expect(updatedCategory.color, '#FF5733');
      expect(updatedCategory.createdAt, DateTime.parse('2024-01-20T10:30:00Z'));
    });
  });
}
