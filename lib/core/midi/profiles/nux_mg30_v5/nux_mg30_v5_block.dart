/// One of the twelve blocks the NUX MG-30 (V5) signal chain is built from, in
/// the order signal reaches them - not the eight-block shorthand
/// (COMP/EFX/AMP/IR/EQ/MOD/DLY/RVB) used as an example elsewhere: the real unit
/// also has a Wah, a Noise Gate, a Send/Return loop and a Volume block.
///
/// Eleven of them are named in the unit's own MIDI implementation chart;
/// [volume] is not, and appears here because the unit shows it in the chain
/// regardless - see `nuxMg30V5Blocks`.
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
  volume,
}
