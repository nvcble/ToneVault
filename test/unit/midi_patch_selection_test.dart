import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_patch_selection.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/patch_selection_defaults.dart';

const _defaults = PatchSelectionDefaults(
  usesBankSelect: true,
  bankSelectMsb: 0,
  verificationStatus: MidiSupportLevel.needsHardwareVerification,
);

void main() {
  group('buildPatchSelectionMessages', () {
    test('sends Bank Select MSB then Program Change for patch 1', () {
      final messages = buildPatchSelectionMessages(
        defaults: _defaults,
        channel: 0,
        patchNumber: 1,
      );

      expect(messages, hasLength(2));
      expect(messages[0], isA<ControlChangeMessage>());
      expect(messages[0].toBytes(), [0xB0, bankSelectMsbCc, 0]);
      expect(messages[1], isA<ProgramChangeMessage>());
      expect(messages[1].toBytes(), [0xC0, 0]);
    });

    test('counts patches from 1, sending patch 21 as Program Change 20', () {
      final messages = buildPatchSelectionMessages(
        defaults: _defaults,
        channel: 0,
        patchNumber: 21,
      );

      expect(messages.last.toBytes(), [0xC0, 20]);
    });

    test('sends only Program Change when Bank Select is turned off', () {
      const noBankSelect = PatchSelectionDefaults(
        usesBankSelect: false,
        bankSelectMsb: 0,
        verificationStatus: MidiSupportLevel.needsHardwareVerification,
      );

      final messages = buildPatchSelectionMessages(
        defaults: noBankSelect,
        channel: 0,
        patchNumber: 1,
      );

      expect(messages, [isA<ProgramChangeMessage>()]);
    });

    test('sends Bank Select LSB too when the defaults name one', () {
      const withLsb = PatchSelectionDefaults(
        usesBankSelect: true,
        bankSelectMsb: 0,
        bankSelectLsb: 3,
        verificationStatus: MidiSupportLevel.needsHardwareVerification,
      );

      final messages = buildPatchSelectionMessages(
        defaults: withLsb,
        channel: 0,
        patchNumber: 1,
      );

      expect(messages, hasLength(3));
      expect(messages[1].toBytes(), [0xB0, bankSelectLsbCc, 3]);
    });

    test('an override replaces the default field by field', () {
      final messages = buildPatchSelectionMessages(
        defaults: _defaults,
        override: const PatchSelectionOverride(bankSelectMsb: 5),
        channel: 0,
        patchNumber: 1,
      );

      expect(messages.first.toBytes(), [0xB0, bankSelectMsbCc, 5]);
    });

    test('an override can turn Bank Select off entirely', () {
      final messages = buildPatchSelectionMessages(
        defaults: _defaults,
        override: const PatchSelectionOverride(usesBankSelect: false),
        channel: 0,
        patchNumber: 1,
      );

      expect(messages, [isA<ProgramChangeMessage>()]);
    });

    test('sends every message on the same channel', () {
      final messages = buildPatchSelectionMessages(
        defaults: _defaults,
        channel: 3,
        patchNumber: 1,
      );

      expect(messages[0].toBytes()[0], 0xB0 | 3);
      expect(messages[1].toBytes()[0], 0xC0 | 3);
    });
  });
}
