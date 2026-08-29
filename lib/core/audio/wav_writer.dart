import 'dart:typed_data';

/// Samples wrapped in the header that makes them a file a player will open.
///
/// A WAV because it is the one format every platform plays without a codec, and
/// because writing one is this short: forty-four bytes of header and then the samples
/// as signed sixteen-bit numbers. Nothing here knows what the sound is of.
const int defaultSampleRate = 22050;

/// One channel, sixteen bits a sample. Samples outside -1..1 are clipped rather than
/// wrapped: a clipped peak is a moment of harshness, where a wrapped one is a crack.
Uint8List wavOfSamples(
  List<double> samples, {
  int sampleRate = defaultSampleRate,
}) {
  const int bitsPerSample = 16;
  const int channels = 1;
  final int dataBytes = samples.length * 2;

  final bytes = ByteData(44 + dataBytes);
  _ascii(bytes, 0, 'RIFF');
  bytes.setUint32(4, 36 + dataBytes, Endian.little);
  _ascii(bytes, 8, 'WAVE');

  _ascii(bytes, 12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little); // The length of this chunk.
  bytes.setUint16(20, 1, Endian.little); // 1 is uncompressed PCM.
  bytes.setUint16(22, channels, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(
    28,
    sampleRate * channels * bitsPerSample ~/ 8,
    Endian.little,
  );
  bytes.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  bytes.setUint16(34, bitsPerSample, Endian.little);

  _ascii(bytes, 36, 'data');
  bytes.setUint32(40, dataBytes, Endian.little);

  for (var index = 0; index < samples.length; index++) {
    final clamped = samples[index].clamp(-1.0, 1.0);
    bytes.setInt16(44 + index * 2, (clamped * 32767).round(), Endian.little);
  }

  return bytes.buffer.asUint8List();
}

void _ascii(ByteData bytes, int offset, String text) {
  for (var index = 0; index < text.length; index++) {
    bytes.setUint8(offset + index, text.codeUnitAt(index));
  }
}
