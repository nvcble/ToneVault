import 'package:flutter/material.dart';

import '../formatting/app_date_format.dart';

/// A date nobody has to give, picked from a calendar rather than typed.
///
/// Reads "Not set" until there is one and offers to clear it again, so a date
/// entered by mistake does not have to stay. Typing is not offered on purpose:
/// a hand-typed date is a parsing question, and the picker cannot produce one
/// outside [firstDate] and [lastDate].
class OptionalDateField extends StatelessWidget {
  const OptionalDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.enabled = true,
    super.key,
  });

  final String label;
  final DateTime? value;

  /// Called with the date picked, or null when it is cleared.
  final ValueChanged<DateTime?> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// False while a save is in flight, so one tap cannot become two writes.
  final bool enabled;

  /// Opens on the date it holds, and on the latest one allowed when it holds
  /// none: a date about something already owned is a date in the recent past.
  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = value;

    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Optional',
          suffixIcon: date == null
              ? const Icon(Icons.calendar_today)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear ${label.toLowerCase()}',
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(date == null ? 'Not set' : formatDate(date)),
      ),
    );
  }
}
