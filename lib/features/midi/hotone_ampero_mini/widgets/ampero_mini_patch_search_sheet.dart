import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../data/ampero_mini_patch_layout.dart';

/// Finds one of the pedal's 198 patches by its own label ("P02-1"), by the raw
/// index a capture shows ("003"), or by a name read off the device.
///
/// A sheet rather than a field on the page: the page it is opened from puts
/// twelve slots on one screen without scrolling, and a permanent search field
/// costs two rows of them. Picking a result returns its patch number, which
/// the page pre-selects - and pre-selecting is what moves the grid to the page
/// holding it, so nothing is sent to the pedal by searching.
class AmperoMiniPatchSearchSheet extends StatefulWidget {
  const AmperoMiniPatchSearchSheet({this.names = const {}, super.key});

  /// Patch number to the name read off the device, for the few that have one.
  final Map<int, String> names;

  /// The patch the user picked, or null if they closed the sheet.
  static Future<int?> show(
    BuildContext context, {
    Map<int, String> names = const {},
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AmperoMiniPatchSearchSheet(names: names),
  );

  /// How many matches are offered at once - enough to choose from without the
  /// sheet becoming the patch list it is meant to jump into.
  static const int maxResults = 8;

  @override
  State<AmperoMiniPatchSearchSheet> createState() =>
      _AmperoMiniPatchSearchSheetState();
}

class _AmperoMiniPatchSearchSheetState
    extends State<AmperoMiniPatchSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = _matches();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Patch number or label',
                isDense: true,
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('No patch matches that'),
              )
            else
              for (final number in matches)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(amperoMiniPatchLabel(number)),
                  subtitle: Text(
                    widget.names[number] ??
                        (amperoMiniIsUserPatch(number)
                            ? 'User patch'
                            : 'Factory patch - not reachable yet'),
                  ),
                  onTap: () => Navigator.of(context).pop(number),
                ),
          ],
        ),
      ),
    );
  }

  List<int> _matches() => [
    for (var n = 0; n < amperoMiniPatchCount; n++)
      if (_matchesQuery(n)) n,
  ].take(AmperoMiniPatchSearchSheet.maxResults).toList();

  bool _matchesQuery(int number) {
    if (_query.isEmpty) {
      return false;
    }
    return amperoMiniPatchLabel(number).toLowerCase().contains(_query) ||
        number.toString().padLeft(3, '0').contains(_query) ||
        (widget.names[number]?.toLowerCase().contains(_query) ?? false);
  }
}
