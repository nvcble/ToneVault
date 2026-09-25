import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_device_registry.dart';
import 'package:tone_vault/core/midi/midi_feature.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';

void main() {
  group('NuxMg30V5Profile', () {
    const profile = NuxMg30V5Profile();

    test('identifies the original V5 unit, not Gen2', () {
      expect(profile.id, 'nux_mg30_v5');
      expect(profile.manufacturer, 'NUX');
      expect(profile.model, 'MG-30');
      expect(profile.firmwareVersion, 'V5');
    });

    test('only offers USB, the one connection type the brief confirms', () {
      expect(profile.connectionTypes, [MidiTransportType.usb]);
    });

    test(
      'reports the capability matrix confirmed by the V5 chart and QuickTone',
      () {
        expect(
          profile.supportLevelOf(MidiFeature.patchSelection),
          MidiSupportLevel.needsHardwareVerification,
        );
        expect(
          profile.supportLevelOf(MidiFeature.sceneSwitching),
          MidiSupportLevel.partiallySupported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.blockBypass),
          MidiSupportLevel.partiallySupported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.parameterControl),
          MidiSupportLevel.supported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.patchEditing),
          MidiSupportLevel.supported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.effectModelSelection),
          MidiSupportLevel.supported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.signalChainEditing),
          MidiSupportLevel.unsupported,
        );
        // Partial, not unknown: reading a slot's dump is verified against the
        // real unit, while decoding most of it and writing one back are not.
        expect(
          profile.supportLevelOf(MidiFeature.patchTransfer),
          MidiSupportLevel.partiallySupported,
        );
        expect(
          profile.supportLevelOf(MidiFeature.irManagement),
          MidiSupportLevel.partiallySupported,
        );
      },
    );

    test('ships every CC the V5 chart and QuickTone confirm', () {
      expect(profile.parameterDefinitions, hasLength(86));
    });

    test('offers a plain Program Change candidate, marked unverified', () {
      final defaults = profile.patchSelectionDefaults;

      expect(defaults, isNotNull);
      expect(defaults.usesBankSelect, isFalse);
      expect(defaults.bankSelectMsb, isNull);
      expect(defaults.bankSelectLsb, isNull);
      expect(
        defaults.verificationStatus,
        MidiSupportLevel.needsHardwareVerification,
      );
    });

    test('is reachable from the registry by its id', () {
      expect(
        MidiDeviceRegistry.findById('nux_mg30_v5'),
        isA<NuxMg30V5Profile>(),
      );
      expect(MidiDeviceRegistry.findById('does_not_exist'), isNull);
    });

    test('is one of the devices the catalog offers', () {
      expect(MidiDeviceRegistry.profiles, contains(isA<NuxMg30V5Profile>()));
    });
  });
}
