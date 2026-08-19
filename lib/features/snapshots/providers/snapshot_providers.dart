import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/rig_snapshot_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../configurations/providers/configuration_providers.dart';
import '../../controls/providers/control_providers.dart';
import '../../pedalboards/providers/pedalboard_providers.dart';
import '../data/rig_snapshot_repository.dart';

final Provider<RigSnapshotDao> rigSnapshotDaoProvider =
    Provider<RigSnapshotDao>(
      (ref) => RigSnapshotDao(ref.watch(appDatabaseProvider)),
    );

/// Capture reads a rig, its pedals' controls and their configurations, which is
/// why this one repository needs four accessors.
final Provider<RigSnapshotRepository> rigSnapshotRepositoryProvider =
    Provider<RigSnapshotRepository>(
      (ref) => RigSnapshotRepository(
        ref.watch(rigSnapshotDaoProvider),
        ref.watch(pedalboardDaoProvider),
        ref.watch(configurationDaoProvider),
        ref.watch(pedalControlDaoProvider),
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
