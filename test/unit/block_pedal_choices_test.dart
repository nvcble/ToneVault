import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/block_pedal_choices.dart';
import '../support/chain_rows.dart';

/// What the picker offers for a block: which pedals suit it, which are merely
/// possible, and which are not around to plug in at all.
void main() {
  final drive = chainPedal(1, 'Caline PureSky');
  final verb = chainPedal(2, 'Boss RV-6', category: PedalCategory.reverb);

  PedalChoices choicesFor(
    SignalBlockType type, {
    List<Pedal> pedals = const [],
    List<ChainBlock> chain = const [],
    int? exceptBlockId,
  }) {
    return pedalChoices(
      pedals: pedals,
      chain: chain,
      blockType: type,
      exceptBlockId: exceptBlockId,
    );
  }

  test('splits the inventory into what suits the block and the rest', () {
    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [drive, verb],
    );

    // The rest is still offered: it is the user's board, and a reverb in the
    // overdrive block is their call.
    expect(choices.suited, [drive]);
    expect(choices.others, [verb]);
  });

  test('a block no category stands for offers everything as others', () {
    final choices = choicesFor(SignalBlockType.input, pedals: [drive, verb]);

    expect(choices.suited, isEmpty);
    expect(choices.others, [drive, verb]);
  });

  test('a pedal already elsewhere on the rig is not offered twice', () {
    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [drive, verb],
      chain: [chainBlock(10, pedal: drive)],
    );

    expect(choices.suited, isEmpty);
    expect(choices.others, [verb]);
  });

  test('whatever is in this block stays on its own list', () {
    // Otherwise the block would exclude itself, and the pedal in it would look
    // unset the moment the picker opened.
    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [drive, verb],
      chain: [chainBlock(10, pedal: drive)],
      exceptBlockId: 10,
    );

    expect(choices.suited, [drive]);
  });

  test('an empty block holds nothing back', () {
    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [drive],
      chain: [chainBlock(10, type: SignalBlockType.delay, label: 'Slapback')],
    );

    expect(choices.suited, [drive]);
  });

  test('a sold or replaced pedal is not around to plug in', () {
    final sold = chainPedal(3, 'Sold Drive', status: PedalStatus.sold);
    final replaced = chainPedal(4, 'Old Drive', status: PedalStatus.replaced);

    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [sold, replaced, drive],
    );

    expect(choices.suited, [drive]);
    expect(choices.others, isEmpty);
  });

  test('a backup or a stored pedal is offered', () {
    // Putting one on a board is how a rig gets planned.
    final backup = chainPedal(3, 'Spare Drive', status: PedalStatus.backup);
    final stored = chainPedal(4, 'Boxed Drive', status: PedalStatus.storage);

    final choices = choicesFor(
      SignalBlockType.overdrive,
      pedals: [backup, stored],
    );

    expect(choices.suited, [backup, stored]);
  });
}
