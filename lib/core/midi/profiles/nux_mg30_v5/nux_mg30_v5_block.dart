/// One of the eleven blocks the NUX MG-30 (V5) signal chain is built from, as
/// named in the unit's own MIDI implementation chart - not the eight-block
/// shorthand (COMP/EFX/AMP/IR/EQ/MOD/DLY/RVB) used as an example elsewhere:
/// the real unit also has a Wah, a Noise Gate and a Send/Return loop.
enum NuxMg30Block {
  wah,
  compressor,
  effect,
  amp,
  eq,
  noiseGate,
  modulation,
  delay,
  reverb,
  ir,
  sendReturn,
}
