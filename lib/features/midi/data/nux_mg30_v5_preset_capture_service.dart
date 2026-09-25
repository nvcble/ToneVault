import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';
import 'midi_preset_capture_repository.dart';
import 'nux_mg30_v5_preset_reader.dart';

/// What to do with a program number this unit already has a capture for -
/// asked once up front for the whole run, not once per slot: 128 duplicate
/// dialogs would not be a usable strategy, and the diagnostic brief only
/// asks for a clear one, not a granular one.
enum PresetCaptureDecision { skip, overwrite }

/// What one capture-all run did.
typedef PresetCaptureSummary = ({
  int captured,
  int overwritten,
  int skipped,
  List<PresetCaptureFailure> failures,
  bool stoppedEarly,
});

/// One program number that could not be captured, and why - most likely a
/// timeout, since this command has never been confirmed against V5
/// hardware.
typedef PresetCaptureFailure = ({int programNumber, String message});

/// Identical failures folded together with a count.
///
/// 128 slots failing for one reason is one fact, not 128. Showing only the
/// slot numbers - which is all the summary used to show - hid whether the run
/// hit a timeout, a refused send or a database error, and those need
/// completely different fixes.
typedef PresetCaptureFailureGroup = ({String message, int count});

List<PresetCaptureFailureGroup> groupCaptureFailures(
  List<PresetCaptureFailure> failures,
) {
  final counts = <String, int>{};
  for (final failure in failures) {
    counts.update(failure.message, (count) => count + 1, ifAbsent: () => 1);
  }
  return [
    for (final entry in counts.entries)
      (message: entry.key, count: entry.value),
  ];
}

/// Walks every program number in [firstProgramNumber, lastProgramNumber],
/// reading and storing a raw capture (plus a best-effort decode) for each -
/// the bulk form of a single preset read, repeated across a whole bank.
///
/// One program number failing - most likely a timeout - is recorded in the
/// summary rather than stopping the rest, the same way `PresetImportService`
/// already treats one preset's failure as independent of the others.
class NuxMg30V5PresetCaptureService {
  const NuxMg30V5PresetCaptureService(this._reader, this._captures);

  final NuxMg30V5PresetReader _reader;
  final MidiPresetCaptureRepository _captures;

  Future<PresetCaptureSummary> captureAll({
    required int unitId,
    required String deviceProfileId,
    required PresetCaptureDecision onDuplicate,
    int firstProgramNumber = 0,
    int lastProgramNumber = 127,
    Duration readTimeout = const Duration(seconds: 5),
    int giveUpAfterConsecutiveFailures = 5,
    void Function(int completed, int total)? onProgress,
  }) async {
    var captured = 0;
    var overwritten = 0;
    var skipped = 0;
    var consecutiveFailures = 0;
    var stoppedEarly = false;
    final failures = <PresetCaptureFailure>[];
    final total = lastProgramNumber - firstProgramNumber + 1;

    for (
      var programNumber = firstProgramNumber;
      programNumber <= lastProgramNumber;
      programNumber++
    ) {
      try {
        final existing = await _captures.findByProgramNumber(
          unitId,
          programNumber,
        );
        if (existing != null && onDuplicate == PresetCaptureDecision.skip) {
          skipped++;
          continue;
        }

        final response = await _reader.readPreset(
          programNumber,
          timeout: readTimeout,
        );
        DecodedNuxMg30V5Preset? decoded;
        try {
          decoded = decodeNuxMg30V5Preset(response);
        } catch (_) {
          decoded = null;
        }

        await _captures.saveCapture(
          pedalId: unitId,
          deviceProfileId: deviceProfileId,
          programNumber: programNumber,
          rawSysEx: response.toBytes(),
          decoded: decoded,
        );
        existing != null ? overwritten++ : captured++;
        consecutiveFailures = 0;
      } catch (error) {
        failures.add((programNumber: programNumber, message: error.toString()));
        consecutiveFailures++;
      } finally {
        onProgress?.call(programNumber - firstProgramNumber + 1, total);
      }

      // A run that has failed this many times in a row will fail the same way
      // for every slot left, and the user would wait minutes to be told so.
      if (consecutiveFailures >= giveUpAfterConsecutiveFailures) {
        stoppedEarly = true;
        break;
      }
    }

    return (
      captured: captured,
      overwritten: overwritten,
      skipped: skipped,
      failures: failures,
      stoppedEarly: stoppedEarly,
    );
  }
}
