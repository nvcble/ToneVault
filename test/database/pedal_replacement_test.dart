import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/replacements/data/replacement_repository.dart';
import '../support/repositories.dart';

/// A change log that cannot write, to prove a swap is only kept if it can also
/// be recorded.
class _BrokenChangeLog extends ChangeLogRepository {
  _BrokenChangeLog(super.dao);

  @override
  Future<void> record(ChangeEntry entry) async => throw Exception('disk gone');
}

/// What replacing a pedal does: the outgoing one is retired rather than removed,
/// and the swap is written once as a row and once to the history.
void main() {
  late AppDatabase database;
  late ReplacementRepository repository;
  late DateTime now;
  late int pureSky;
  late int mg30;

  Future<int> addPedal(String name) {
    return pedalRepository(database, clock: () => now).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
  }

  Future<Pedal> pedal(int id) async => (await database.pedalDao.findPedal(id))!;

  Future<int> replace({
    int? outgoing,
    int? incoming,
    String? reason,
    String? notes,
    DateTime? replacedAt,
  }) {
    return repository.replacePedal(
      outgoingPedalId: outgoing ?? pureSky,
      incomingPedalId: incoming ?? mg30,
      reason: reason,
      notes: notes,
      replacedAt: replacedAt,
    );
  }

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<List<ChangeLog>> history(int pedalId) async {
    final changes = await database.changeLogDao.entriesOf(pedalId);
    return changes
        .where((entry) => entry.changeType == ChangeType.pedalReplaced)
        .toList();
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 8, 19, 12);
    repository = replacementRepository(database, clock: () => now);
    pureSky = await addPedal('Caline PureSky');
    mg30 = await addPedal('NUX MG-30');
  });

  tearDown(() => database.close());

  test('retires the outgoing pedal and leaves the new one as it was', () async {
    await replace();

    expect((await pedal(pureSky)).status, PedalStatus.replaced);
    expect((await pedal(mg30)).status, PedalStatus.active);
  });

  test('never deletes the pedal it replaced', () async {
    await replace();

    // Both pedals are still there, and the swap now holds them in place: the
    // foreign keys restrict the delete on either side.
    final pedals = pedalRepository(database, clock: () => now);
    for (final id in [pureSky, mg30]) {
      await expectLater(pedals.deletePedal(id), throwsA(isA<AppFailure>()));
      expect(await database.pedalDao.findPedal(id), isNotNull);
    }
  });

  test('records the swap once, naming both pedals', () async {
    await replace(reason: 'wanted the amp models');

    final entries = await history(pureSky);
    expect(entries.single.oldText, 'Caline PureSky');
    expect(entries.single.newText, 'NUX MG-30');
    expect(entries.single.reason, 'wanted the amp models');
    expect(entries.single.createdAt, now);

    // Filed under the pedal that left, so the new pedal's own timeline does not
    // open with an event about someone else.
    expect(await history(mg30), isEmpty);
  });

  test('keeps the reason and the notes on the swap itself', () async {
    await replace(reason: 'wanted the amp models', notes: 'sold locally');

    final swap = (await repository.watchSwaps(pureSky).first).single;
    expect(swap.replacement.reason, 'wanted the amp models');
    expect(swap.replacement.notes, 'sold locally');
    expect(swap.replacement.replacedAt, now);
  });

  test('leaves out a reason and notes that were not given', () async {
    await replace(reason: '   ', notes: '');

    final swap = (await repository.watchSwaps(pureSky).first).single;
    expect(swap.replacement.reason, isNull);
    expect(swap.replacement.notes, isNull);
    expect((await history(pureSky)).single.reason, isNull);
  });

  test('takes a date entered after the fact, but not a future one', () async {
    final lastMonth = DateTime.utc(2026, 7, 4);
    await replace(replacedAt: lastMonth);

    final swap = (await repository.watchSwaps(pureSky).first).single;
    expect(swap.replacement.replacedAt, lastMonth);

    final vox = await addPedal('Vox Wah');
    await expectLater(
      replace(
        outgoing: mg30,
        incoming: vox,
        replacedAt: now.add(const Duration(days: 1)),
      ),
      failsWith('A replacement cannot be dated in the future.'),
    );
  });

  test('reads the swap from either pedal, with both sides of it', () async {
    await replace();

    for (final id in [pureSky, mg30]) {
      final swap = (await repository.watchSwaps(id).first).single;
      expect(swap.outgoing.name, 'Caline PureSky');
      expect(swap.incoming.name, 'NUX MG-30');
    }
  });

  test('reads a chain of swaps newest first', () async {
    await replace();
    final helix = await addPedal('Line 6 HX Stomp');
    now = now.add(const Duration(days: 30));
    await replace(outgoing: mg30, incoming: helix);

    // The MG-30 is on both swaps: it took over from one pedal and was later
    // retired by another.
    final swaps = await repository.watchSwaps(mg30).first;
    expect(swaps.map((swap) => swap.incoming.name), [
      'Line 6 HX Stomp',
      'NUX MG-30',
    ]);
  });

  test('refuses a pedal replacing itself', () async {
    await expectLater(
      replace(incoming: pureSky),
      failsWith('A pedal cannot replace itself.'),
    );
  });

  test('refuses to replace one pedal twice, saying what took over', () async {
    await replace();
    final vox = await addPedal('Vox Wah');

    await expectLater(
      replace(incoming: vox),
      failsWith('Caline PureSky was already replaced by NUX MG-30.'),
    );
    expect(await repository.watchSwaps(pureSky).first, hasLength(1));
  });

  test('reports a pedal that is no longer there on either side', () async {
    final gone = await addPedal('Sold Already');
    expect(await database.pedalDao.deletePedal(gone), isTrue);

    await expectLater(
      replace(outgoing: gone),
      failsWith('That pedal no longer exists.'),
    );
    await expectLater(
      replace(incoming: gone),
      failsWith('That replacement pedal no longer exists.'),
    );
  });

  test('rolls the whole swap back if it cannot be recorded', () async {
    final unrecordable = replacementRepository(
      database,
      changeLog: _BrokenChangeLog(ChangeLogDao(database)),
    );

    await expectLater(
      unrecordable.replacePedal(
        outgoingPedalId: pureSky,
        incomingPedalId: mg30,
      ),
      failsWith('Could not record this replacement.'),
    );

    // No half-done swap: no row, and the pedal is still in the rig.
    expect(await repository.watchSwaps(pureSky).first, isEmpty);
    expect((await pedal(pureSky)).status, PedalStatus.active);
  });
}
