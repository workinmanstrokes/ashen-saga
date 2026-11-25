# Ashen Saga: Sunstone Hunt

**First make it open on a real phone — then make the Sunstone hunt hard, loud, and worth replaying.**

A Viking Age survivors-style RPG set in Norway, 900 AD. You play Eirik Ash-Hand
hunting the Sunstone across 3 acts, each 3 minutes with a boss at the end.
Weapons auto-attack — hammer, throwing axes, rune nova — enemies come in growing
waves, you collect XP runestone shards and pick 1 of 3 boons when you level up.

Stack: **Godot with GDScript, exported to Android.** The game already exists in
Godot, so this update fixes its Android export and reuses the full 3-act game
and story from the same project as the working web build — no rewrite.

> **Identity note (tester red flag):** several similarly named Ashen RPGs and
> roguelikes already exist on Android. This game's full title is
> **Ashen Saga: Sunstone Hunt** (package `com.workinmanstrokes.ashensaga`) —
> use the full title everywhere it is listed, so it is findable.

## Where things stand

- Full 3-act story works; headless test passed; web version plays through to the ending.
- **Tester update applied (VEX 4.0/10, grade D):** per-act difficulty restored
  (spawn rate + enemy HP/damage scaling per act, no easy tuning anywhere),
  boons widened to 19 with gated evolutions, per-weapon hit sounds, shard
  pickup sound wired in, act-intro saga beats told in-game, and
  meta-progression (banked Sunstone shards + Endless mode after a full clear).
- **Still unfinished:** the Godot Android build has NOT yet been proven on a
  real phone — no install / first-run / Act 1 log exists yet. That proof is
  step 1 and it gates everything else; see `docs/ANDROID-PHONE-TEST.md` for
  the exact procedure and `docs/RELEASE-MODEL.md` for the release decision.
- Game tester score: **4.0/10 (grade D)** (before this update).

## Tester-priority checklist (in order — do not skip ahead)

1. **Fix and prove the Godot Android build first.** Get it opening on one real
   phone, then record install, first run, Act 1 completion and stability.
   Do not tune anything else until this passes. Procedure:
   `docs/ANDROID-PHONE-TEST.md`. Status: **NOT YET PROVEN — procedure written,
   no phone log recorded.**
2. **Restore the intended difficulty** in the playable build and test it as a
   full 3-act run, logging deaths, boss times and level reached per act.
   Set a clear difficulty target rather than shipping the easier web tuning.
   Status: **CODE DONE** — per-act spawn interval and enemy HP/damage
   multipliers live in `scripts/act_director.gd`; a full 3-act run log is
   still needed to confirm the target table below.
3. **Add minimum viable sound:** weapon hits, shard pickup, level-up, boss
   spawn and boss death. Placeholder effects are enough to test feel.
   Status: **CODE DONE** — `audio/sound_manager.gd` generates all five
   placeholder cues (per-weapon hit pitch), `player.collect_shard()` plays
   the pickup cue, mute toggle in settings.
4. **Make each act visibly and mechanically distinct:** different enemy mix,
   arena dressing and boss behaviour, plus a short saga beat between acts so
   the Sunstone hunt is told in-game. Status: **CODE DONE** — per-act mix,
   dressing, boss HP/behaviour, spawn scaling, plus an act-intro saga beat
   shown before each act (`act_director.show_intro_beat()`).
5. **Widen the build choices that fight repetition:** more boons, weapon
   upgrades or evolutions, and state which combinations are meant to carry
   Acts 2–3. Status: **CODE DONE** — 19 boons (was 12), 4 evolutions
   (was 3), evolutions gated on their prerequisite boon, 4 named carry
   combos in `scripts/boons.gd`.
6. **Only then decide the Android release model** and test it on at least two
   real phones with different screen sizes before calling this an Android build.
   Status: **DECISION DEFERRED** — see `docs/RELEASE-MODEL.md`. Default until
   then: sideloaded APK; Play Store AAB only after the two-phone pass.

## Difficulty target (to confirm with a skilled run)

| Measure | Target |
| --- | --- |
| Deaths per full 3-act run | 1–2 for a skilled player (not 0, not a wall) |
| Boss kill time | Act 1 ~20–30 s, Act 2 ~30–45 s, Act 3 ~45–60 s |
| Level reached per act | Act 1 end ~5–6, Act 2 end ~10–12, Act 3 end ~15+ |
| Act 1 first-time clear | Achievable, but only after learning the boon picks |

Difficulty is enforced per act in `scripts/act_director.gd`:

| Act | Spawn interval | Enemy HP | Enemy damage | Boss HP |
| --- | --- | --- | --- | --- |
| Act 1 — The Burning Shore | 2.2 s | ×1.00 | ×1.00 | 600 |
| Act 2 — The Pinewood Dark | 1.7 s | ×1.35 | ×1.25 | 950 |
| Act 3 — The Sunstone Hall | 1.3 s | ×1.80 | ×1.50 | 1400 |

Log every run with `scripts/run_log.gd` — deaths, boss times, level per act,
device, and stability notes — and compare against this table before retuning.

## Meta-progression (replay hook)

A 9-minute run with nothing after the first clear was a tester red flag, so
runs now persist across sessions (`user://ashen_saga_meta.json`):

- Every boss kill banks **1 Sunstone shard**.
- Best act reached, total runs, and full 3-act clears are recorded.
- Clearing all 3 acts unlocks **Endless mode**: the Act III mix replays with
  +25% enemy HP/damage per wave and no timer (`act_director.start_endless()`).

## Controls, performance, monetisation

| Area | This build |
| --- | --- |
| Controls | Touch drag-to-move (virtual joystick); on-screen buttons are at least 48 px touch targets; keyboard WASD/arrows work on desktop for testing. Pause / mute / restart / quit on the pause screen. |
| Performance target | 60 fps on a mid-range Android phone; `gl_compatibility` renderer for the widest device range; landscape 1280×720 viewport, stretch `canvas_items` / `expand`. No performance measurements on a real phone yet — record FPS in the phone test log. |
| Sound | 5 placeholder cues (hit per weapon, shard pickup, level-up, boss spawn, boss death) generated in code; mute toggle in settings; real .wav/.ogg files can replace them in `res://audio/`. |
| Monetisation | None in this build — no ads, no in-app purchases. The release model (Play Store vs sideload vs itch.io) is decided only after the two-phone test; see `docs/RELEASE-MODEL.md`. |

## Phone test log template

```
Date:
Device / screen size:
Build (APK/AAB, commit):
Install: [ ] OK  [ ] FAIL — notes:
First run / opens: [ ] OK  [ ] FAIL — notes:
Act 1 completed: [ ] YES  [ ] NO — where it stopped:
Stability (crashes / freezes / FPS):
Sound heard (hit / pickup / level-up / boss spawn / boss death):
Run log: deaths __ | boss times __ | level per act __
```

## Project layout

- `project.godot` — Godot project settings, viewport, orientation, Android config
- `export_presets.cfg` — Android APK/AAB and Web export presets
- `scenes/main.tscn` — root scene wiring menu, acts, saga beats, ending
- `scripts/player.gd` — Eirik: movement, touch controls, auto-attack weapons, HP, XP
- `scripts/act_director.gd` — per-act timers, enemy mix, arena dressing, boss behaviour, saga beats
- `scripts/boons.gd` — boon pool, weapon upgrades/evolutions, and level-up choices
- `scripts/run_log.gd` — run logging (deaths, boss times, level per act, device) + meta-progression
- `audio/sound_manager.gd` — placeholder SFX player (hits, pickups, level-up, boss cues) with mute
- `docs/ANDROID-PHONE-TEST.md` — clean-export / install / Act 1 phone-proof procedure
- `docs/RELEASE-MODEL.md` — release-model decision (deferred until the two-phone test)
- `BUILD-PLAN.md` — the full App Builder plan for this update

## Open questions

- What Godot version is the existing project on, and is the Android failure an
  export, signing, or runtime crash?
- What is the intended difficulty target — expected deaths, boss kill time, and
  level reached per act for a skilled run?
- Which Android release model is intended — Play Store AAB, sideloaded APK, or
  itch.io — and which two phones and screen sizes are available to test?
