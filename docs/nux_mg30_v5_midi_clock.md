# NUX MG-30 (V5) and MIDI Clock

What ToneVault sends, what is actually known about whether the MG-30 listens,
and the hardware test that would settle it.

Status: **Unverified.** ToneVault can generate a standards-compliant MIDI
Clock stream, and that part is tested. Whether the original MG-30 on firmware
V5.0.2 does anything at all with an incoming clock has not been established,
by documentation or by hardware.

## What was looked at

| Source | What it says about clock |
| --- | --- |
| The unit's V5 MIDI implementation chart (86 Control Change rows, the basis of `nuxMg30V5Parameters`) | Nothing. It is a CC chart only: no System Real-Time section, and no row for tempo or BPM anywhere in it. Its rows stop at CC 85. |
| QuickTone 2.4.12.27's Custom MIDI page | Nothing about clock, and - checked on the real application, 2026-10-14 - **no Tap Tempo row either**. An earlier version of this document and of `nuxMg30V5AssignableParameters` claimed tap tempo could be pointed at a CC here. That was wrong. Switch A and B were not checked. |
| `docs/nux_mg30_v5_patch_format.md` (the decoded QuickTone patch export) | Patch data only. Nothing about real-time messages. |

So no confirmed source for this device mentions MIDI Clock in either
direction. In particular, nothing has been found that distinguishes clock
**in** from clock **out**, which is the distinction that matters here: a unit
that transmits clock is not thereby a unit that follows one.

`nuxMg30V5Capabilities[MidiFeature.tempoSync]` is therefore
`needsHardwareVerification`: the unit has a tap-tempo footswitch and delay
times that follow it, so there is something for a clock to drive and a
specific, standards-compliant thing to try - but nothing confirms it works.

## What ToneVault sends

`MidiClockGenerator` sends only the three System Real-Time messages a clock
stream is made of, and nothing device-specific:

- `0xFA` Start, once, when the user presses Start Clock
- `0xF8` Timing Clock, 24 to the quarter note, repeatedly
- `0xFC` Stop, once, when the stream ends

The interval is `60,000,000 / (BPM × 24)` microseconds - 20,833 µs at 120 BPM.
Each pulse is aimed at a deadline computed from its pulse number, so rounding
cannot accumulate. No CC is sent as a substitute for a clock, and no SysEx is
guessed at.

### Timing honesty

Pulses are scheduled with ordinary Dart timers on the UI isolate. At 120 BPM
the target gap is 20.8 ms, which is a little over one frame, so a garbage
collection or a busy frame will make a pulse late. The panel measures and
shows mean and worst lateness, and counts pulses whose moment passed while
the app was not running rather than firing a catch-up burst (a burst would
read on the wire as a sudden jump in tempo). **No hard real-time guarantee is
claimed.**

Android's `MidiInputPort.send` does accept a `System.nanoTime` timestamp for
scheduled delivery, and `flutter_midi_command` passes one through, which would
largely remove this jitter. It is not used: Dart has no way to read
`System.nanoTime`, so there is no common reference to convert a deadline into,
and `MidiTransport.send` carries no timestamp. Doing it would need a small
platform channel plus a change to the transport contract - worth it only if
measured jitter turns out to stop the unit locking on.

### Attempted, not delivered

USB MIDI here is fire-and-forget. `MidiCommand.sendData` returns nothing, and
`sendDataAwaitingDelivery` completes immediately for a platform-routed
(non-BLE) device. Nothing in the app can confirm a single byte arrived, so the
diagnostic says "pulses sent (attempted)" and never claims delivery.

## Hardware test procedure

Needs the MG-30 and an Android device with USB OTG. ToneVault is Android-only;
QuickTone runs on a laptop, so the two cannot be plugged into the unit at
once.

1. Connect the MG-30 to the Android device by USB and allow the permission
   prompt.
2. Open the device's Patches screen → menu → **MIDI Diagnostics**, and press
   **Connect**. The clock panel's "Output:" line should name the MG-30.
3. On the unit, select a patch with an **audible delay** - a quarter-note
   repeat is easiest to hear.
4. Set the delay time to something recognisable, and note what the unit shows
   for tempo or delay time before anything is sent.
5. Press **Send Test Pulse**. Nothing should audibly happen; this only proves
   the port accepts a one-byte message without error.
6. Set the panel to **60 BPM** and press **Start Clock**.
7. Watch two things for at least 20 seconds: the delay repeats against the
   pulse, and whatever the unit displays for tempo. Record both.
8. Set the panel to **120 BPM** while the stream is still running (the stream
   is re-aimed, not restarted) and watch the same two things again.
9. Press **Stop Clock**.
10. Write down what happened, including "nothing" - and check the panel's own
    figures for the run: measured rate, worst lateness, pulses missed.

### Reading the result

- **Delay time changed with the clock** - the unit follows incoming clock.
  Record which BPM values were tried and move `tempoSync` to `supported` (or
  `partiallySupported` if only some blocks followed).
- **Nothing changed at either tempo** - no evidence it follows clock. Do not
  record `unsupported` from this alone unless a device setting for clock
  source has been ruled out: check the unit's own system/global menu for
  anything naming MIDI, sync, clock or tempo source first, and note what the
  menu actually offers. A setting that has to be found by guesswork is a
  finding in itself.
- **Jitter was large** (worst lateness over a few milliseconds, or pulses
  missed) - the result is inconclusive for a unit that was *almost* locking;
  retry with the screen awake and nothing else running before concluding.

Whatever happens, the MG-30's **displayed BPM** changing is a separate claim
from its delay *following* the clock. Record them separately.

## The CC route is closed

Worth stating plainly, because it changes what the clock test is for: there is
now **no known way to set or tap the MG-30's tempo over MIDI by CC**. The V5
chart has no tempo row, and QuickTone's Custom MIDI page - the one place a CC
could have been bound to the tap-tempo footswitch - has no Tap Tempo row at
all. Tried on hardware on 2026-10-14: mapping a CC to Tap Tempo in ToneVault
did not move the unit's tempo, which is exactly what that missing row predicts.

ToneVault still lets you assign a CC to Tap Tempo on the CC Mapping screen, in
case a route turns up that none of these sources documents. Be aware that an
arbitrary CC number is very likely to be a real parameter in the chart - CC 25
is a block knob, not a free slot - so an unlucky choice will quietly change the
amp rather than the tempo.

That leaves incoming MIDI Clock as the only remaining candidate, and the
hardware test above as the only way to settle it.

## If the MG-30 ignores incoming clock too

Then the unit's internal tempo cannot be driven from ToneVault at all, and the
honest thing is to say so rather than keep hunting. In that case:

- The diagnostic stays useful on its own terms: it is a correct clock
  generator, and the same panel will answer the same question for the Ampero
  Mini or any device the app grows into.
- ToneVault keeps its own tempo for its own metronome and display, and does
  not pretend the pedal's BPM has changed.
- The remaining avenues, in order of how likely they are to lead anywhere:
  1. a clock or sync setting in the unit's own global/system menu that has to
     be switched on before it will follow anything;
  2. a MIDI capture of QuickTone while it is talking to the unit, which is the
     same artifact the patch-write work is already waiting on - if QuickTone
     can set a tempo, the bytes that do it are in that capture;
  3. NUX support, asked the narrow question: does MG-30 firmware V5.0.2 act on
     incoming MIDI Clock, and is there any documented message that sets its
     tempo?
