# Android phone test — prove the build before tuning anything

Tester priority #1 (VEX 4.0/10): the Godot Android build would not open on a
phone, so the stated Android target currently has no playable build. Nothing
else in the tester list is tuned or judged until this procedure passes on one
real phone. Do the steps in order and record the result in the log at the end.

## Prerequisites

- Godot **4.3** (see `config/features` in `project.godot`) with the Android
  export templates installed for that exact version.
- One real Android phone (any size for this first proof; the second phone with
  a different screen size comes at milestone 6).
- `adb` on the test machine, and the phone with USB debugging on
  (or install the APK by file transfer).

## 1. Clean export

1. Delete any previous export: remove `../builds/ashen-saga-android.apk`.
2. In Godot: Project → Export → preset **Android** → Export Project.
   Confirm the preset is the APK variant (`variant/export_format=0` in
   `export_presets.cfg`); do NOT switch to AAB yet — that decision is
   deferred to `docs/RELEASE-MODEL.md`.
3. If the export fails, record the exact error before changing anything:
   is it an export error, a signing error, or does the APK build but fail
   at runtime? (This answers open question 1.)

## 2. Install

```
adb install -r ../builds/ashen-saga-android.apk
```

Record: install OK / FAIL + the exact error text. The package name is
`com.workinmanstrokes.ashensaga`, display name "Ashen Saga: Sunstone Hunt".

## 3. First run

1. Launch the app from the phone's launcher (not from adb).
2. Record: opens to the main menu? Any black screen, crash, or freeze?
3. Note the phone model, Android version, and screen size.

## 4. Act 1 completion

1. Start a run, play through Act 1 to the boss (3 minutes + boss fight).
2. Record: Act 1 completed YES/NO, and where it stopped if not.
3. Check the run log afterwards: `scripts/run_log.gd` writes
   `user://ashen_saga_run_log.json` — deaths, boss time, and level per act
   must be present for the run to count as logged.

## 5. Stability

Play at least 10 minutes total. Record any crash, freeze, or stutter, and
an approximate FPS feel (smooth / occasional hitches / constant stutter).
Check the sound cues: weapon hit, shard pickup, level-up, boss spawn,
boss death — and that the mute toggle silences them.

## Log (copy into the README phone test log)

```
Date:
Device / screen size:
Build (APK, commit):
Install: [ ] OK  [ ] FAIL — notes:
First run / opens: [ ] OK  [ ] FAIL — notes:
Act 1 completed: [ ] YES  [ ] NO — where it stopped:
Stability (crashes / freezes / FPS):
Sound heard (hit / pickup / level-up / boss spawn / boss death):
Run log: deaths __ | boss times __ | level per act __
```

## If it fails

Do NOT start tuning difficulty, boons, or sound in response. Fix the
export/install/open failure first, re-export clean, and re-run this
procedure from step 1. The failure class (export / signing / runtime
crash) goes in the log and answers open question 1.
