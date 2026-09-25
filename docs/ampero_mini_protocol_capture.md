# Finding the Ampero Mini's patch-read command

Everything in ToneVault past "select a patch" is blocked on one unknown: the
SysEx command that asks the Ampero Mini for a patch, and the reply it sends
back. This document is how to obtain it.

## Why this is needed at all

What is currently known about this pedal's protocol:

| Fact | Confidence |
| --- | --- |
| 198 patches, 99 user + 99 factory | OFFICIAL (Hotone spec table) |
| Banks of 3, numbered from 01: user `P01-1`…`P33-3`, then factory `F01-1`…`F33-3` | VERIFIED ON HARDWARE (app-vs-pedal comparison at the boundary) |
| Program Change `n` selects user patch index `n` | VERIFIED ON HARDWARE (PC 1 loaded P01-2) |
| A Program Change for a **factory** patch does nothing | VERIFIED ON HARDWARE (PC 99, F01-1, changed nothing) |
| SysEx prefix `21 25 7F 4D 50 2D 32 12 00 02 06` | VERIFIED ON HARDWARE (two captures) |
| `…06 05 00 00 00 78` = periodic status, ~1/sec | UNKNOWN meaning |
| `…06 04 <hi> <lo>` = a 14-bit counter emitted with each status | VERIFIED ON HARDWARE as a counter; what it counts is UNKNOWN |
| Any report of **which patch the pedal has loaded** | **UNKNOWN — the pedal is not known to say** |
| Any command to **read** a patch | **UNKNOWN — this is the blocker** |
| Any command to **write** a patch | **UNKNOWN** |
| Whether Bank Select reaches the factory patches | UNKNOWN — four layouts are offered as an EXPERIMENTAL probe, none confirmed |

Both understood messages are *broadcasts* — the pedal talking unprompted — and
neither carries patch information. Nothing so far is a request/response pair, so
there is no confirmed way to ask the pedal anything. Guessing is not an
acceptable substitute: a fabricated read command would produce a patch editor
that silently shows invented data.

**Retracted 2026-09-16:** `04 01 <index>` was previously recorded here as "I
have loaded patch `<index>`". It is not. It is the low half of the counter above.
The capture that seemed to confirm it was ten footswitch presses made roughly a
second apart, which a once-a-second counter matches by coincidence; a second
capture advanced it ten times while at most two patches changed. Treat this as
the standing example of why a coincidence across one capture is not
verification.

## The reliable way to get it: watch Hotone's own editor

Hotone ships a desktop editor that genuinely reads and writes Ampero Mini
patches. That proves the commands exist, and it means they can be observed
rather than guessed. Capturing that traffic gives real bytes.

### 1. Install the tools

- **Ampero Mini's official editor** from Hotone's support/download page for the
  product. Confirm it connects to your pedal and lists your patches *before*
  capturing anything — if the editor cannot talk to the pedal, there is nothing
  to capture.
- **Wireshark**, from <https://www.wireshark.org/download.html>. During
  installation, tick **USBPcap**. That component is what makes USB traffic
  visible; Wireshark alone cannot see it.
- Reboot after installing, as USBPcap installs a driver.

### 2. Identify which USB device the pedal is

With the pedal plugged in, open Wireshark. The capture interface list will show
`USBPcap1`, `USBPcap2`, … one per USB root hub. Click each and read the device
list it prints; the pedal appears as a Hotone/Ampero device or as a generic USB
Audio/MIDI device. Note which `USBPcapN` holds it.

### 3. Capture the smallest possible exchange

Small captures are much easier to read than large ones, so keep the session
tight:

1. Close the editor.
2. Start capture on the right `USBPcapN`.
3. Open the editor, let it connect.
4. Do **exactly one** thing: read a single patch — ideally `P02-1`, whose index
   is `3`, which gives us a known small value to look for in the bytes.
5. Stop the capture immediately.
6. Save as `.pcapng`.

Then repeat as a **separate** capture for each additional operation, one
operation per file:

- read one patch (`P02-1`, index `3`) — the priority, this is the blocker
- read a *second*, different patch (`P03-1`, index `6`) — the difference
  between the two requests is where the patch number lives
- the editor's "read all"/sync, if it has one
- **selecting a factory patch such as `F01-1` in the editor** — second priority.
  A plain Program Change does not do it, so whatever the editor sends instead is
  the only known route to the factory half
- changing patches with the pedal's own footswitches while the editor is open —
  if the editor follows along, it is being told somehow, and that is the report
  this app currently has no way to receive
- a patch *write*, only if you are willing to have that patch overwritten

### 4. Narrow to the MIDI bytes

In Wireshark's filter bar:

```
usb.transfer_type == 0x01 && usb.data_len > 0
```

That keeps isochronous/interrupt USB-MIDI payload frames and drops the
enumeration chatter. The bytes you want look like the prefix we already know:
`21 25 7F 4D 50 2D 32 12`. Filtering for that string in **Edit → Find Packet →
Packet bytes → Hex value** jumps straight to the interesting frames.

USB-MIDI wraps MIDI in 4-byte packets with a leading Cable/Index Number byte,
so a SysEx stream is spread across frames and the raw hex will have an extra
byte every four. That is expected — it is unwrapped when the bytes are decoded.

### 5. What to send back

For each capture: the `.pcapng` file, plus a note of exactly which patch you
read and what its label was on the pedal. The label matters — it is what lets a
byte in the request be tied to a known patch index rather than guessed at.

## Alternative if the editor route is unavailable

If the official editor will not run or will not see the pedal, the fallback is
to probe candidate command bytes from inside ToneVault: send the known prefix
with unobserved type bytes (`00`–`03`, `06`, `07`, …) and watch MIDI Monitor for
a reply.

This is a genuinely riskier path and is deliberately not built yet. Unknown
SysEx sent to a device can hit commands that are not reads — factory reset and
firmware-update modes are both plausible — and we currently have **no backup
capability**, because backing up patches requires the very read command being
searched for. A wipe would be unrecoverable.

## What gets unblocked once a read command is confirmed

In order: read one patch → decode and store it → Sync All → patch details →
local editing → encode → send to pedal → read-back verification → backup and
restore. None of it can honestly be built before then, which is why the patch
list currently shows slots rather than patches.

## What works today without it

- Connect, and select **every user patch**, `P01-1` to `P33-3` (Program Change).
- Try to reach a **factory patch** with Bank Select — EXPERIMENTAL. Double-tapping
  a struck-through factory tile opens a sheet of four candidate layouts, each sent
  only when the user presses Send:

  | Attempt | Hypothesis |
  | --- | --- |
  | `CC0=1, CC32=0, PC n` | the factory half as bank 1, `n` counted from `F01-1` |
  | `CC0=0, CC32=1, PC n` | the same with the bank in the LSB |
  | `CC0=1, PC n` | bank 1 with no LSB sent at all |
  | `CC0=0, CC32=0, PC <absolute index>` | in case the plain PC only failed because the pedal sat in another bank (dropped above index 127) |

  Bank Select is safe to try where blind SysEx is not: CC 0 and CC 32 are reserved
  by the MIDI spec for exactly this, so the worst case is that the pedal ignores it
  or lands somewhere unexpected, which a footswitch undoes. **Whether any layout
  works is UNKNOWN and cannot be learned from this end** — the pedal has no
  confirmed way to report the patch it loaded, so the sheet asks the user to watch
  the pedal and reports "sent", never "selected". If a layout is ever confirmed on
  hardware, promote it into `HotoneAmperoMiniProfile.patchSelectionDefaults` and
  make `amperoMiniIsSelectableOverMidi` accept the factory half.
- See what this app last sent, labelled as a send and nothing more. Following the
  pedal's own footswitch changes is *not* possible: no message it broadcasts says
  which patch it has loaded.
- Record and export MIDI captures as JSON from **MIDI Diagnostics** in the patch
  list's overflow menu — which is how both existing captures were produced.
