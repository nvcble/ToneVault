import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/patch_validator.dart';

/// What a patch and a scene may be called.
void main() {
  test('a name is required, and says which thing needs one', () {
    expect(PatchValidator.patchName(''), 'Enter a patch name.');
    expect(PatchValidator.patchName('   '), 'Enter a patch name.');
    expect(PatchValidator.sceneName(null), 'Enter a scene name.');
  });

  test('a name is measured after trimming', () {
    expect(PatchValidator.patchName('  Worship Clean  '), isNull);
    expect(
      PatchValidator.sceneName('V' * (PatchValidator.nameMaxLength + 1)),
      'Use at most ${PatchValidator.nameMaxLength} characters.',
    );
    expect(
      PatchValidator.sceneName('V' * PatchValidator.nameMaxLength),
      isNull,
    );
  });

  test('a draft is judged on its name alone', () {
    // Notes are the user's own words about a sound and there is nothing to get
    // wrong in them, so a draft with none is a valid draft.
    expect(PatchValidator.patchDraft(const PatchDraft(name: 'Verse')), isNull);
    expect(
      PatchValidator.sceneDraft(const SceneDraft(name: '', notes: 'Loud')),
      'Enter a scene name.',
    );
  });

  test('a draft normalizes its own text before it is stored', () {
    final draft = const PatchDraft(
      name: '  Worship Clean ',
      notes: '   ',
    ).normalized();

    expect(draft.name, 'Worship Clean');
    // Blank notes are nothing, not an empty line the user has to clear later.
    expect(draft.notes, isNull);
  });
}
