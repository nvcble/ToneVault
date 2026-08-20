import 'package:flutter/material.dart';

/// The name-and-brand search box above the pedal list.
///
/// Keeps its own controller so typing does not depend on a rebuild arriving,
/// and reports every keystroke: filtering an in-memory list is instant, so
/// there is nothing to debounce.
class PedalSearchField extends StatefulWidget {
  const PedalSearchField({
    required this.query,
    required this.onChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<PedalSearchField> createState() => _PedalSearchFieldState();
}

class _PedalSearchFieldState extends State<PedalSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(PedalSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when something else cleared the filter, which would otherwise leave
    // the box reading as though it were still narrowing the list.
    if (widget.query != _controller.text) _controller.text = widget.query;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by name or brand',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: const OutlineInputBorder(),
        // Listening to the controller rather than rebuilding the whole field
        // keeps the clear button in step with the text without a setState that
        // would fight the parent's own rebuild.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                ),
        ),
      ),
    );
  }
}
