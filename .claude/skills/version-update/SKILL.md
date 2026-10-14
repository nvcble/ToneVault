---
name: version-update
description: Bump the app version in pubspec.yaml. Use when the user asks to update, bump or release a version - "/version-update major", "bump the minor version", "release a patch version". Takes one of major, minor or patch.
allowed-tools: Read, Edit
---

# Version update

`pubspec.yaml` line 4 (`version: <major>.<minor>.<patch>+<build>`) is the only
place a version lives. Android reads it through `flutter.versionName` and
`flutter.versionCode`, so nothing else needs editing - do not touch
`build.gradle.kts`.

## The bump

Read the current version, then apply exactly one of these by the argument
given, and **always** increment the build number:

| Argument | Part bumped | 1.0.0+1 becomes |
| -------- | ----------- | --------------- |
| `major`  | major       | `2.0.0+2`       |
| `minor`  | minor       | `1.1.0+2`       |
| `patch`  | patch       | `1.0.1+2`       |

A bump resets the parts to its right to zero. The build number only ever goes
up, never resets - it is what the Play Store orders uploads by.

## Steps

1. If the argument is missing or is not one of `major`, `minor`, `patch`: say
   so with the three valid options and stop. Never guess which was meant.
2. Read `pubspec.yaml` and parse the current version.
3. Edit that one line.
4. Report it as `1.0.0+1 → 1.1.0+2`, and say the change is not committed.

Committing is a separate step - see the `git-commit-push` skill.
