import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_validator.dart';

void main() {
  final now = DateTime.utc(2026, 8, 19);

  PedalDraft draftWith({
    String name = 'Caline PureSky',
    String? brand,
    DateTime? purchaseDate,
    String? notes,
  }) {
    return PedalDraft(
      name: name,
      type: PedalType.analog,
      category: PedalCategory.overdrive,
      brand: brand,
      purchaseDate: purchaseDate,
      notes: notes,
    );
  }

  group('name', () {
    test('rejects empty and whitespace-only names', () {
      expect(PedalValidator.name(null), isNotNull);
      expect(PedalValidator.name(''), isNotNull);
      expect(PedalValidator.name('   '), isNotNull);
    });

    test('accepts a name at the column limit but not past it', () {
      expect(PedalValidator.name('a' * PedalValidator.nameMaxLength), isNull);
      expect(
        PedalValidator.name('a' * (PedalValidator.nameMaxLength + 1)),
        isNotNull,
      );
    });

    test('measures length after trimming', () {
      final padded = ' ${'a' * PedalValidator.nameMaxLength} ';
      expect(PedalValidator.name(padded), isNull);
    });
  });

  group('brand', () {
    test('treats blank as not provided', () {
      expect(PedalValidator.brand(null), isNull);
      expect(PedalValidator.brand('  '), isNull);
    });

    test('rejects a brand past the column limit', () {
      expect(
        PedalValidator.brand('b' * (PedalValidator.brandMaxLength + 1)),
        isNotNull,
      );
    });
  });

  group('purchaseDate', () {
    test('accepts today and the past', () {
      expect(PedalValidator.purchaseDate(null, now: now), isNull);
      expect(PedalValidator.purchaseDate(now, now: now), isNull);
      expect(
        PedalValidator.purchaseDate(
          now.subtract(const Duration(days: 365)),
          now: now,
        ),
        isNull,
      );
    });

    test('rejects the future', () {
      expect(
        PedalValidator.purchaseDate(
          now.add(const Duration(days: 1)),
          now: now,
        ),
        isNotNull,
      );
    });
  });

  group('draft', () {
    test('passes a complete valid draft', () {
      expect(
        PedalValidator.draft(
          draftWith(brand: 'Caline', purchaseDate: now),
          now: now,
        ),
        isNull,
      );
    });

    test('reports the name problem first', () {
      final problem = PedalValidator.draft(
        draftWith(name: '', brand: 'b' * 200),
        now: now,
      );
      expect(problem, PedalValidator.name(''));
    });
  });

  group('normalized', () {
    test('trims the name and blanks out empty optional text', () {
      final normalized = draftWith(
        name: '  Caline PureSky  ',
        brand: '   ',
        notes: '',
      ).normalized();

      expect(normalized.name, 'Caline PureSky');
      expect(normalized.brand, isNull);
      expect(normalized.notes, isNull);
    });

    test('trims optional text that has content', () {
      final normalized = draftWith(brand: '  Caline  ').normalized();
      expect(normalized.brand, 'Caline');
    });

    test('leaves non-text fields untouched', () {
      final purchased = DateTime.utc(2024, 1, 2);
      final normalized = draftWith(purchaseDate: purchased).normalized();

      expect(normalized.purchaseDate, purchased);
      expect(normalized.type, PedalType.analog);
      expect(normalized.category, PedalCategory.overdrive);
    });
  });
}
