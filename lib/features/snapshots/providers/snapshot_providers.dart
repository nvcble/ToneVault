import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/rig_snapshot_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../configurations/providers/configuration_providers.dart';
import '../../controls/providers/control_providers.dart';
import '../../patches/providers/patch_providers.dart';
import '../../pedalboards/providers/pedalboard_providers.dart';
import '../data/rig_snapshot_repository.dart';
import '../data/snapshot_settings.dart';

final Provider<RigSnapshotDao> rigSnapshotDaoProvider =
    Provider<RigSnapshotDao>(
      (ref) => RigSnapshotDao(ref.watch(appDatabaseProvider)),
    );

/// What a pedal on the rig was set to: a configuration of its own, or a scene of
/// one of a unit's patches. Reading either takes four accessors, which is why it
/// is not the repository's own job.
final Provider<SnapshotSettings> snapshotSettingsProvider =
    Provider<SnapshotSettings>(
      (ref) => SnapshotSettings(
        ref.watch(configurationDaoProvider),
        ref.watch(pedalControlDaoProvider),
        ref.watch(patchDaoProvider),
        ref.watch(sceneDaoProvider),
      ),
    );

final Provider<RigSnapshotRepository> rigSnapshotRepositoryProvider =
    Provider<RigSnapshotRepository>(
      (ref) => RigSnapshotRepository(
        ref.watch(rigSnapshotDaoProvider),
        ref.watch(pedalboardDaoProvider),
        ref.watch(signalChainDaoProvider),
        ref.watch(snapshotSettingsProvider),
      ),
    );

/// One rig's snapshots, newest first.
final StreamProviderFamily<List<RigSnapshot>, int> rigSnapshotsProvider =
    StreamProvider.family<List<RigSnapshot>, int>(
      (ref, pedalboardId) =>
          ref.watch(rigSnapshotRepositoryProvider).watchSnapshots(pedalboardId),
    );

/// One snapshot. Watched rather than read once so a snapshot deleted behind an
/// open screen is noticed.
final StreamProviderFamily<RigSnapshot?, int> rigSnapshotProvider =
    StreamProvider.family<RigSnapshot?, int>(
      (ref, snapshotId) =>
          ref.watch(rigSnapshotRepositoryProvider).watchSnapshot(snapshotId),
    );

/// What one snapshot recorded, in the order signal ran through it.
final StreamProviderFamily<List<SnapshotEntry>, int> snapshotEntriesProvider =
    StreamProvider.family<List<SnapshotEntry>, int>(
      (ref, snapshotId) =>
          ref.watch(rigSnapshotRepositoryProvider).watchEntries(snapshotId),
    );
