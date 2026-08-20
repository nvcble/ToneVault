import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../history/providers/history_providers.dart';
import '../data/pedal_photo_repository.dart';
import '../data/pedal_repository.dart';
import '../data/pedal_seeder.dart';
import '../data/photo_picker.dart';

final Provider<PedalDao> pedalDaoProvider = Provider<PedalDao>(
  (ref) => PedalDao(ref.watch(appDatabaseProvider)),
);

final Provider<PedalRepository> pedalRepositoryProvider =
    Provider<PedalRepository>(
      (ref) => PedalRepository(
        ref.watch(pedalDaoProvider),
        ref.watch(changeLogRepositoryProvider),
      ),
    );

/// Overridden in tests, which have no camera and no gallery.
final Provider<PhotoPicker> photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotos(),
);

/// Inside the app's own documents directory, which needs no permission and is
/// backed up and removed with the app.
Future<Directory> _pedalPhotoFolder() async {
  final documents = await getApplicationDocumentsDirectory();
  return Directory('${documents.path}/pedal_photos');
}

final Provider<PedalPhotoRepository> pedalPhotoRepositoryProvider =
    Provider<PedalPhotoRepository>(
      (ref) => PedalPhotoRepository(
        ref.watch(photoPickerProvider),
        _pedalPhotoFolder,
      ),
    );

/// The whole inventory, ordered by name. Drift pushes a new list whenever the
/// `pedals` table changes, so screens never refresh by hand.
final StreamProvider<List<Pedal>> pedalListProvider =
    StreamProvider<List<Pedal>>(
      (ref) => ref.watch(pedalRepositoryProvider).watchPedals(),
    );

/// The stomps or blocks inside one multi-effects unit, keyed by the unit's id.
/// Kept out of [pedalListProvider] on purpose; see `PedalDao.watchPedals`.
final StreamProviderFamily<List<Pedal>, int> componentPedalListProvider =
    StreamProvider.family<List<Pedal>, int>(
      (ref, hostPedalId) =>
          ref.watch(pedalRepositoryProvider).watchComponentPedals(hostPedalId),
    );

/// Only used by the debug-only seed action in settings.
final Provider<PedalSeeder> pedalSeederProvider = Provider<PedalSeeder>(
  (ref) => PedalSeeder(ref.watch(pedalRepositoryProvider)),
);

final StreamProviderFamily<Pedal?, int> pedalProvider =
    StreamProvider.family<Pedal?, int>(
      (ref, pedalId) => ref.watch(pedalRepositoryProvider).watchPedal(pedalId),
    );
