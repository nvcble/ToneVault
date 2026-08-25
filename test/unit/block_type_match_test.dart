import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/block_type_match.dart';

/// What a pedal of each category is for, said as a block of a signal chain.
void main() {
  test('every category has a block it fills', () {
    // A category with no answer would leave the picker with nothing to preselect
    // when the user adds a block by choosing the pedal that goes in it.
    for (final category in PedalCategory.values) {
      expect(blockTypeFor(category), isNotNull, reason: category.name);
    }
  });

  test('a category spelled differently still finds its block', () {
    expect(blockTypeFor(PedalCategory.equalizer), SignalBlockType.eq);
    expect(blockTypeFor(PedalCategory.noiseGate), SignalBlockType.gate);
    expect(blockTypeFor(PedalCategory.ampSim), SignalBlockType.amp);
    expect(blockTypeFor(PedalCategory.cabinetIr), SignalBlockType.cab);
    expect(
      blockTypeFor(PedalCategory.multiEffects),
      SignalBlockType.multiEffect,
    );
  });

  test('a category with no block of its own is custom', () {
    expect(blockTypeFor(PedalCategory.other), SignalBlockType.custom);
  });

  test('a block asks back for the categories that fill it', () {
    expect(categoriesFor(SignalBlockType.eq), {PedalCategory.equalizer});
    expect(categoriesFor(SignalBlockType.overdrive), {PedalCategory.overdrive});
  });

  test('a block nothing is categorised as asks for nothing in particular', () {
    // An input, an IR loader or a DI is a real thing to plan and no category
    // stands for one, so the picker falls back to offering everything.
    expect(categoriesFor(SignalBlockType.input), isEmpty);
    expect(categoriesFor(SignalBlockType.output), isEmpty);
    expect(categoriesFor(SignalBlockType.ir), isEmpty);
    expect(categoriesFor(SignalBlockType.di), isEmpty);
    // A split and a merge are where the signal parts and rejoins, which is a
    // junction rather than a pedal, so anything owned can stand in one.
    expect(categoriesFor(SignalBlockType.split), isEmpty);
    expect(categoriesFor(SignalBlockType.merge), isEmpty);
  });

  test('a category is always among what its own block asks for', () {
    for (final category in PedalCategory.values) {
      final type = blockTypeFor(category);
      if (type == SignalBlockType.custom) continue;
      expect(categoriesFor(type), contains(category), reason: category.name);
    }
  });
}
