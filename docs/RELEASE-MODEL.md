# Release model — decision deferred until the two-phone test

Tester priority #6 (VEX 4.0/10): decide the Android release model only after
the build is proven on a real phone and the tester fixes are in. That point
has not been reached yet, so this document records the decision as
**deferred**, not made.

## Current default (testing only)

- **Sideloaded APK** (`variant/export_format=0` in `export_presets.cfg`,
  version `0.3.0-tester-update`, version code 2). This is the build used for
  the first real-phone proof in `docs/ANDROID-PHONE-TEST.md`.

## Options, in order of likelihood

1. **Play Store (AAB)** — only after the build passes on **two real phones
   with different screen sizes**. Switching means setting
   `variant/export_format=1` and raising the version code; nothing else in
   the project changes.
2. **Sideloaded APK** — stays the fallback if the store route is not wanted.
3. **itch.io** — fallback distribution for the APK if neither of the above
   fits; no store listing work has been done for it.

## What is NOT decided

- No store listing, screenshots, or description have been written.
- No price: the game ships with **no ads and no in-app purchases** in this
  build, and no monetisation is added until the release model is chosen.
- The two test phones (models + screen sizes) are not yet named — record
  them in the phone test log when they are known.

## Identity

List the game everywhere as **Ashen Saga: Sunstone Hunt**
(package `com.workinmanstrokes.ashensaga`). Several similarly named Ashen
RPGs/roguelikes already exist on Android; the Sunstone Hunt subtitle is
what makes this one findable.
