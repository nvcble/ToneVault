import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_status.dart';

/// What the pedal list is currently narrowed down to.
///
/// A null category or status means "any": the absence of a choice, rather than
/// a choice that happens to match everything.
typedef PedalFilter = ({
  String query,
  PedalCategory? category,
  PedalStatus? status,
});

/// The unnarrowed list: every pedal, in the order the database gave them.
const PedalFilter everyPedal = (query: '', category: null, status: null);

/// Whether anything is being held back, which decides between "no pedals yet"
/// and "nothing matches".
bool isNarrowed(PedalFilter filter) =>
    filter.query.trim().isNotEmpty ||
    filter.category != null ||
    filter.status != null;

/// A filtered list together with what it was drawn from, so the screen can say
/// how much it is hiding and offer only the categories actually owned.
typedef PedalSearch = ({
  List<Pedal> matches,
  int total,
  List<PedalCategory> categories,
  PedalFilter filter,
});

/// Applies [filter] to [pedals].
///
/// The whole inventory already streams into memory for the list and the home
/// tally, so narrowing it is a walk rather than another query: the numbers can
/// never disagree with the list they came from.
PedalSearch searchPedals({
  required List<Pedal> pedals,
  required PedalFilter filter,
}) {
  final terms = filter.query.trim().toLowerCase();
  return (
    matches: pedals
        .where((pedal) => _matches(pedal, filter: filter, terms: terms))
        .toList(),
    total: pedals.length,
    categories: _categoriesOwned(pedals),
    filter: filter,
  );
}

bool _matches(
  Pedal pedal, {
  required PedalFilter filter,
  required String terms,
}) {
  if (filter.category != null && pedal.category != filter.category) {
    return false;
  }
  if (filter.status != null && pedal.status != filter.status) return false;
  if (terms.isEmpty) return true;
  // Brand counts as part of the name: someone hunting a Boss pedal types
  // "boss", not the model they have forgotten.
  return pedal.name.toLowerCase().contains(terms) ||
      (pedal.brand?.toLowerCase().contains(terms) ?? false);
}

/// The categories present in the collection, in signal-chain order.
///
/// Offering all twenty-odd would bury the five someone owns.
List<PedalCategory> _categoriesOwned(List<Pedal> pedals) {
  final owned = pedals.map((pedal) => pedal.category).toSet();
  return PedalCategory.values.where(owned.contains).toList();
}

/// How much of the collection is on screen, for the line above the list.
String describeMatches(PedalSearch search) {
  if (!isNarrowed(search.filter)) {
    return '${search.total} ${search.total == 1 ? 'pedal' : 'pedals'}';
  }
  return '${search.matches.length} of ${search.total} pedals';
}
