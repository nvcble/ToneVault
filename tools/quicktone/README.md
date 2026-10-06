# Reading the MG-30's own tables out of QuickTone

`extract_mg30_tables.js` is a read-only scan of NUX's Windows editor
(QuickTone V2.4.12.27), run for interoperability with hardware we own: it is how
`nux_mg30_v5_model_names.dart` was written, and it produced
`docs/nux_mg30_v5_quicktone_tables.json`.

```
node tools/quicktone/extract_mg30_tables.js /path/to/QuickTone.exe
```

The editor is never executed - the file is read as bytes. Two things inside it
are what the app needs:

- a per-device string table listing each block's models in the unit's own order,
  with `BYPASS` ahead of model 1;
- a JSON document (a NUL-terminated string in `.rdata`, keyed `"12. BRIT 800"`)
  giving each model's knobs: `languageKey` for the label, `midiCC` for the knob's
  index inside its block, and `parameter1`/`parameter2` for its range. Labels
  resolve through the editor's own `"KEY"="VALUE"` translation table.

Offsets are hard-coded for this build. They are a starting point for the next
version rather than a contract: re-find them by searching for a known model name
(`15. TOUCH WAH`) and a known label key (`AMP_GAIN`).

What this does **not** give: where a block's model code and knob values sit in a
222-byte preset dump. QuickTone parses that in compiled code, not in a table.
The remaining lead is QuickTone's own patch file ("QuickTone Config", `.bin`):
export a patch, capture the same slot over SysEx, and compare.
