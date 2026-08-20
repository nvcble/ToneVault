import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_filter.dart';

void main() {
  final moment = DateTime.utc(2026, 8, 19);

  Pedal pedal(
    int id,
    String name, {
    String? brand,
    PedalCategory category = PedalCategory.overdrive,
    PedalStatus status = PedalStatus.active,
  }) => Pedal(
    id: id,
    name: name,
    brand: brand,
    type: PedalType.analog,
    category: category,
    status: status,
    createdAt: moment,
    updatedAt: moment,
  );

  final pedals = [
    pedal(1, 'PureSky', brand: 'Caline'),
    pedal(2, 'Blues Driver', brand: 'Boss', status: PedalStatus.storage),
    pedal(3, 'DD-3', brand: 'Boss', category: PedalCategory.delay),
    pedal(4, 'Big Sky', category: PedalCategory.reverb),
  ];

  List<String> names(PedalSearch search) =>
      search.matches.map((pedal) => pedal.name).toList();

  test('no filter leaves the list as it was', () {
    final search = searchPedals(pedals: pedals, filter: everyPedal);

    expect(names(search), ['PureSky', 'Blues Driver', 'DD-3', 'Big Sky']);
    expect(search.total, 4);
    expect(isNarrowed(everyPedal), isFalse);
  });

  test('a search matches the name whatever case it is typed in', () {
    final search = searchPedals(
      pedals: pedals,
      filter: (query: 'sky', category: null, status: null),
    );

    expect(names(search), ['PureSky', 'Big Sky']);
  });

  test('a search matches the brand too, for a model half remembered', () {
    final search = searchPedals(
      pedals: pedals,
      filter: (query: ' BOSS ', category: null, status: null),
    );

    // Trimmed, so a stray space from a keyboard does not empty the list.
    expect(names(search), ['Blues Driver', 'DD-3']);
  });

  test('a category narrows to that category alone', () {
    final search = searchPedals(
      pedals: pedals,
      filter: (query: '', category: PedalCategory.delay, status: null),
    );

    expect(names(search), ['DD-3']);
  });

  test('a status narrows to that status alone', () {
    final search = searchPedals(
      pedals: pedals,
      filter: (query: '', category: null, status: PedalStatus.storage),
    );

    expect(names(search), ['Blues Driver']);
  });

  test('search and filters have to agree, not merely one of them', () {
    final search = searchPedals(
      pedals: pedals,
      filter: (
        query: 'boss',
        category: PedalCategory.overdrive,
        status: PedalStatus.storage,
      ),
    );

    expect(names(search), ['Blues Driver']);
  });

  test('only the categories owned are offered, in signal-chain order', () {
    final search = searchPedals(pedals: pedals, filter: everyPedal);

    expect(search.categories, [
      PedalCategory.overdrive,
      PedalCategory.delay,
      PedalCategory.reverb,
    ]);
  });

  test('the categories offered do not shrink as the list is narrowed', () {
    // Otherwise choosing one category would remove every other choice from the
    // menu, leaving no way back but Clear.
    final search = searchPedals(
      pedals: pedals,
      filter: (query: '', category: PedalCategory.delay, status: null),
    );

    expect(search.categories.length, 3);
  });

  test('the count says how much is hidden only when something is', () {
    expect(
      describeMatches(searchPedals(pedals: pedals, filter: everyPedal)),
      '4 pedals',
    );
    expect(
      describeMatches(searchPedals(pedals: [pedals.first], filter: everyPedal)),
      '1 pedal',
    );
    expect(
      describeMatches(
        searchPedals(
          pedals: pedals,
          filter: (query: 'sky', category: null, status: null),
        ),
      ),
      '2 of 4 pedals',
    );
  });
}
