import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_device_registry.dart';
import 'package:tone_vault/core/midi/midi_feature.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';

void main() {
  group('HotoneAmperoMiniProfile', () {
    const profile = HotoneAmperoMiniProfile();

    test('identifies the Ampero Mini (MP-50)', () {
      expect(profile.id, 'hotone_ampero_mini');
      expect(profile.manufacturer, 'Hotone');
      expect(profile.model, 'Ampero Mini (MP-50)');
    });

    test('only offers USB - confirmed on real hardware', () {
      expect(profile.connectionTypes, [MidiTransportType.usb]);
    });

    test(
      'Program Change patch selection is confirmed, everything else is not',
      () {
        expect(
          profile.supportLevelOf(MidiFeature.patchSelection),
          MidiSupportLevel.supported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.sceneSwitching),
          MidiSupportLevel.unsupported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.blockBypass),
          MidiSupportLevel.unknown,
        );
        expect(
          profile.supportLevelOf(MidiFeature.parameterControl),
          MidiSupportLevel.unknown,
        );
        expect(
          profile.supportLevelOf(MidiFeature.patchEditing),
          MidiSupportLevel.unknown,
        );
        expect(
          profile.supportLevelOf(MidiFeature.patchTransfer),
          MidiSupportLevel.unknown,
        );
      },
    );

    test('invents no parameters or blocks', () {
      expect(profile.parameterDefinitions, isEmpty);
      expect(profile.blockDefinitions, isEmpty);
    });

    test(
      'offers a plain Program Change, confirmed rather than a candidate',
      () {
        final defaults = profile.patchSelectionDefaults;

        expect(defaults.usesBankSelect, isFalse);
        expect(defaults.verificationStatus, MidiSupportLevel.supported);
      },
    );

    test('is reachable from the registry by its id', () {
      expect(
        MidiDeviceRegistry.findById('hotone_ampero_mini'),
        isA<HotoneAmperoMiniProfile>(),
      );
    });

    test('is one of the devices the catalog offers', () {
      expect(
        MidiDeviceRegistry.profiles,
        contains(isA<HotoneAmperoMiniProfile>()),
      );
    });
  });
}
