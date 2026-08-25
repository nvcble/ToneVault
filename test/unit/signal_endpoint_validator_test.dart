import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/signal_source.dart';
import 'package:tone_vault/features/pedalboards/data/signal_endpoint_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_endpoint_validator.dart';

/// The rules the form and the repository both read, without a database or a
/// widget in the way.
void main() {
  const validator = SignalEndpointValidator.draft;

  group('which way round the block faces', () {
    test('an output and a send go somewhere', () async {
      const draft = SignalEndpointDraft(destination: SignalDestination.foh);

      expect(validator(draft, SignalBlockType.output), isNull);
      expect(validator(draft, SignalBlockType.send), isNull);
    });

    test('an input and a return come from somewhere', () async {
      const draft = SignalEndpointDraft(source: SignalSource.guitar);

      expect(validator(draft, SignalBlockType.input), isNull);
      expect(validator(draft, SignalBlockType.fxReturn), isNull);
    });

    test('an ordinary effect is not an edge of the rig', () async {
      expect(
        validator(
          const SignalEndpointDraft(destination: SignalDestination.foh),
          SignalBlockType.delay,
        ),
        'Only an input, output, send or return says where signal comes from or '
        'goes to.',
      );
    });

    test('a split is not one either', () async {
      expect(
        validator(
          const SignalEndpointDraft(source: SignalSource.guitar),
          SignalBlockType.split,
        ),
        isNotNull,
      );
    });

    test('a send fed from somewhere is the wrong way round', () async {
      expect(
        validator(
          const SignalEndpointDraft(source: SignalSource.guitar),
          SignalBlockType.send,
        ),
        'Send is where signal leaves, so it needs somewhere to go rather than '
        'somewhere to come from.',
      );
    });

    test('a return going somewhere is the wrong way round', () async {
      expect(
        validator(
          const SignalEndpointDraft(destination: SignalDestination.foh),
          SignalBlockType.fxReturn,
        ),
        'Return is where signal arrives, so it needs somewhere to come from '
        'rather than somewhere to go.',
      );
    });

    test('an edge that says nothing at all is not described yet', () async {
      expect(
        validator(const SignalEndpointDraft(), SignalBlockType.output),
        'Say where this goes.',
      );
      expect(
        validator(const SignalEndpointDraft(), SignalBlockType.input),
        'Say where this comes from.',
      );
    });
  });

  group('what is at the other end', () {
    test('is optional, because the list already named it', () async {
      // 'Front of house' is a complete answer on most nights.
      expect(
        validator(
          const SignalEndpointDraft(destination: SignalDestination.foh),
          SignalBlockType.output,
        ),
        isNull,
      );
    });

    test('is asked for when the app had no name for it', () async {
      expect(
        validator(
          const SignalEndpointDraft(destination: SignalDestination.custom),
          SignalBlockType.output,
        ),
        'Say what this is, since the app has no name for it.',
      );
      expect(
        validator(
          const SignalEndpointDraft(source: SignalSource.custom, gear: '   '),
          SignalBlockType.input,
        ),
        'Say what this is, since the app has no name for it.',
      );
    });

    test('is accepted once it is in the user own words', () async {
      expect(
        validator(
          const SignalEndpointDraft(
            destination: SignalDestination.custom,
            gear: 'The powered wedge at the back',
          ),
          SignalBlockType.output,
        ),
        isNull,
      );
    });

    test('has a length, like every other name in the app', () async {
      final tooLong = 'a' * (SignalEndpointValidator.gearMaxLength + 1);

      expect(
        validator(
          SignalEndpointDraft(
            destination: SignalDestination.audioInterface,
            gear: tooLong,
          ),
          SignalBlockType.output,
        ),
        'Use at most ${SignalEndpointValidator.gearMaxLength} characters.',
      );
    });
  });

  group('the draft itself', () {
    test('trims what was typed and drops what was left blank', () async {
      const draft = SignalEndpointDraft(
        destination: SignalDestination.foh,
        gear: '  The desk on stage left  ',
        notes: '   ',
      );

      final tidy = draft.normalized();

      expect(tidy.gear, 'The desk on stage left');
      expect(tidy.notes, isNull);
      expect(tidy.destination, SignalDestination.foh);
    });

    test('changes one answer at a time', () async {
      const draft = SignalEndpointDraft(
        destination: SignalDestination.foh,
        gear: 'The desk',
      );

      expect(
        draft.copyWith(destination: SignalDestination.physicalAmpFxReturn).gear,
        'The desk',
      );
    });
  });

  test('an amp input and an amp return are never the same socket', () async {
    // The two ends most easily muddled: one is the front of the amp, the other
    // is halfway through it, and a rig plugged into the wrong one sounds wrong.
    expect(SignalDestination.physicalAmpInput.isPhysicalAmp, isTrue);
    expect(SignalDestination.physicalAmpFxReturn.isPhysicalAmp, isTrue);
    expect(
      SignalDestination.physicalAmpInput,
      isNot(SignalDestination.physicalAmpFxReturn),
    );
    expect(SignalDestination.foh.isPhysicalAmp, isFalse);
    // And the amp's own send is a place signal comes from, never one it goes to.
    expect(SignalSource.physicalAmpFxSend.isPhysicalAmp, isTrue);
  });
}
