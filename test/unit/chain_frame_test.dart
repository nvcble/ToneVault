import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/chain_frame.dart';
import '../support/chain_rows.dart';

/// Which ends of a chain the app still has to guess at.
void main() {
  test('a bare rig is drawn between both guesses', () {
    expect(chainFrame(const []), (drawsStart: true, drawsEnd: true));
  });

  test('an ordinary chain keeps both, because it has said neither', () {
    final chain = [
      chainBlock(10),
      chainBlock(11, type: SignalBlockType.delay, position: 1),
    ];

    expect(chainFrame(chain), (drawsStart: true, drawsEnd: true));
  });

  test('a rig that says where it is fed from loses the guitar', () {
    // A wet-only rig hanging off an amplifier's send starts at a return, and
    // "Guitar" over the top of it would be wrong.
    final chain = [
      chainBlock(10, type: SignalBlockType.fxReturn),
      chainBlock(11, type: SignalBlockType.reverb, position: 1),
    ];

    expect(chainFrame(chain), (drawsStart: false, drawsEnd: true));
  });

  test('a rig that says where it goes loses the far end', () {
    final chain = [
      chainBlock(10),
      chainBlock(11, type: SignalBlockType.output, position: 1),
    ];

    expect(chainFrame(chain), (drawsStart: true, drawsEnd: false));
  });

  test('a send partway down leaves both guesses alone', () {
    // The four cable method: the send says where that trip goes, which is not
    // where the rig finishes.
    final chain = [
      chainBlock(10, type: SignalBlockType.send),
      chainBlock(11, type: SignalBlockType.fxReturn, position: 1),
      chainBlock(12, type: SignalBlockType.delay, position: 2),
    ];

    expect(chainFrame(chain), (drawsStart: true, drawsEnd: true));
  });
}
