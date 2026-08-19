import '../../../core/errors/app_failure.dart';
import 'dev_seed_pedals.dart';
import 'pedal_repository.dart';

/// Loads [devSeedPedals] into an empty database.
///
/// Only useful while developing, and it goes through the repository like any
/// other write, so seeded pedals are ordinary rows with no special casing
/// anywhere else in the app.
class PedalSeeder {
  const PedalSeeder(this._repository);

  final PedalRepository _repository;

  /// Adds every sample pedal and reports how many were added.
  ///
  /// Refuses to run on an inventory that already has pedals in it: pedal names
  /// are not unique, so a second run would silently duplicate all of them.
  Future<int> seed() async {
    final existing = await _repository.watchPedals().first;
    if (existing.isNotEmpty) {
      throw const AppFailure(
        'Sample pedals can only be added to an empty inventory.',
      );
    }

    for (final draft in devSeedPedals) {
      await _repository.createPedal(draft);
    }

    return devSeedPedals.length;
  }
}
