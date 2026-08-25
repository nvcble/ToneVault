/// How signal gets from one block of a chain to the next.
///
/// A series connection is the whole of a rig's routing today: one block feeds
/// the next. [parallel] is what a split feeds and a merge collects, and is why
/// routing is stored as connections rather than read off the block order.
enum SignalConnectionType {
  series,
  parallel;

  String get label => switch (this) {
    SignalConnectionType.series => 'Series',
    SignalConnectionType.parallel => 'Parallel',
  };
}
