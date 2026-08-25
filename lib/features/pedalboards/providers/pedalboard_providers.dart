import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/database/daos/signal_endpoint_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/chain_endpoints.dart';
import '../data/chain_routing.dart';
import '../data/pedalboard_repository.dart';
import '../data/routing_advice.dart';
import '../data/signal_chain_repository.dart';
import '../data/signal_endpoint_repository.dart';
import '../data/signal_routing_repository.dart';

final Provider<PedalboardDao> pedalboardDaoProvider = Provider<PedalboardDao>(
  (ref) => PedalboardDao(ref.watch(appDatabaseProvider)),
);

final Provider<SignalChainDao> signalChainDaoProvider =
    Provider<SignalChainDao>(
      (ref) => SignalChainDao(ref.watch(appDatabaseProvider)),
    );

final Provider<SignalEndpointDao> signalEndpointDaoProvider =
    Provider<SignalEndpointDao>(
      (ref) => SignalEndpointDao(ref.watch(appDatabaseProvider)),
    );

final Provider<PedalboardRepository> pedalboardRepositoryProvider =
    Provider<PedalboardRepository>(
      (ref) => PedalboardRepository(ref.watch(pedalboardDaoProvider)),
    );

final Provider<SignalChainRepository> signalChainRepositoryProvider =
    Provider<SignalChainRepository>(
      (ref) => SignalChainRepository(
        ref.watch(signalChainDaoProvider),
        ref.watch(pedalboardDaoProvider),
        ref.watch(pedalDaoProvider),
      ),
    );

final Provider<SignalRoutingRepository> signalRoutingRepositoryProvider =
    Provider<SignalRoutingRepository>(
      (ref) => SignalRoutingRepository(
        ref.watch(signalChainDaoProvider),
        ref.watch(pedalboardDaoProvider),
      ),
    );

final Provider<SignalEndpointRepository> signalEndpointRepositoryProvider =
    Provider<SignalEndpointRepository>(
      (ref) => SignalEndpointRepository(
        ref.watch(signalEndpointDaoProvider),
        ref.watch(signalChainDaoProvider),
        ref.watch(pedalboardDaoProvider),
      ),
    );

/// Every rig by name. Drift pushes a new list whenever the table changes, so the
/// Rigs screen never refreshes by hand.
final StreamProvider<List<Pedalboard>> pedalboardListProvider =
    StreamProvider<List<Pedalboard>>(
      (ref) => ref.watch(pedalboardRepositoryProvider).watchPedalboards(),
    );

/// One rig. Watched rather than read once so a rig deleted behind an open screen
/// is noticed.
final StreamProviderFamily<Pedalboard?, int> pedalboardProvider =
    StreamProvider.family<Pedalboard?, int>(
      (ref, pedalboardId) =>
          ref.watch(pedalboardRepositoryProvider).watchPedalboard(pedalboardId),
    );

/// One rig's chain in signal order, each block with whatever pedal it holds.
final StreamProviderFamily<List<ChainBlock>, int> signalChainProvider =
    StreamProvider.family<List<ChainBlock>, int>(
      (ref, pedalboardId) =>
          ref.watch(signalChainRepositoryProvider).watchChain(pedalboardId),
    );

/// One rig's cabling. Separate from [signalChainProvider] because most rigs run
/// straight through and never ask for it, and because the chain's own shape does
/// not change when a cable is run.
final StreamProviderFamily<ChainRouting, int> signalRoutingProvider =
    StreamProvider.family<ChainRouting, int>(
      (ref, pedalboardId) =>
          ref.watch(signalRoutingRepositoryProvider).watchRouting(pedalboardId),
    );

/// What one rig's edges reach. Separate again, because most rigs have said
/// nothing about theirs and a chain's own shape does not change when they do.
final StreamProviderFamily<ChainEndpoints, int> signalEndpointsProvider =
    StreamProvider.family<ChainEndpoints, int>(
      (ref, pedalboardId) => ref
          .watch(signalEndpointRepositoryProvider)
          .watchEndpoints(pedalboardId),
    );

/// What is worth mentioning about one rig's wiring.
///
/// Worked out rather than stored, from the three streams a chain screen is already
/// watching. A rig still loading has nothing to say about itself yet.
final ProviderFamily<List<RoutingNote>, int> routingAdviceProvider =
    Provider.family<List<RoutingNote>, int>((ref, pedalboardId) {
      final chain = ref.watch(signalChainProvider(pedalboardId)).valueOrNull;
      if (chain == null) return const [];

      return routingAdvice(
        chain: chain,
        routing:
            ref.watch(signalRoutingProvider(pedalboardId)).valueOrNull ??
            ChainRouting.none,
        endpoints:
            ref.watch(signalEndpointsProvider(pedalboardId)).valueOrNull ??
            ChainEndpoints.none,
      );
    });

/// How many blocks each rig holds, by rig id, for the rig list to read.
///
/// One stream for the whole list rather than one per card, and a rig with an
/// empty chain is simply absent from the map.
final StreamProvider<Map<int, int>> blockCountsProvider =
    StreamProvider<Map<int, int>>(
      (ref) => ref.watch(signalChainRepositoryProvider).watchBlockCounts(),
    );
