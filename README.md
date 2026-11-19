# Ashen Saga

**First make it open on a real phone — then make the Sunstone hunt hard, loud, and worth replaying.**

A Viking Age survivors-style RPG set in Norway, 900 AD. You play Eirik Ash-Hand
hunting the Sunstone across 3 acts, each 3 minutes with a boss at the end.
Weapons auto-attack — hammer, throwing axes, rune nova — enemies come in growing
waves, you collect XP runestone shards and pick 1 of 3 boons when you level up.

Stack: **Godot with GDScript, exported to Android.** The game already exists in
Godot, so this update fixes its Android export and reuses the full 3-act game
and story from the same project as the working web build — no rewrite.

## Where things stand

- Full 3-act story works; headless test passed; web version plays through to the ending.
- **Unfinished:** the Godot version would not open on the phone, the web version
  is tuned easier than the original and has not been confirmed on a real phone
  yet, and there is no sound.
- Game tester score: **4.0/10 (grade D)**.

## Tester-priority checklist (in order — do not skip ahead)

1. **Fix and prove the Godot Android build first.** Get it opening on one real
   phone, then record install, first run, Act 1 completion and stability.
   Do not tune anything else until this passes.
2. **Restore the intended difficulty** in the playable build and test it as a
   full 3-act run, logging deaths, boss times and level reached per act.
   Set a clear difficulty target rather than shipping the easier web tuning.
3. **Add minimum viable sound:** weapon hits, shard pickup, level-up, boss
   spawn and boss death. Placeholder effects are enough to test feel.
4. **Make each act visibly and mechanically distinct:** different enemy mix,
   arena dressing and boss behaviour, plus a short saga beat between acts so
   the Sunstone hunt is told in-game.
5. **Widen the build choices that fight repetition:** more boons, weapon
   upgrades or evolutions, and state which combinations are meant to carry
   Acts 2–3.
6. **Only then decide the Android release model** and test it on at least two
   real phones with different screen sizes before calling this an Android build.

## Difficulty target (to confirm with a skilled run)

| Measure | Target |
| --- | --- |
| Deaths per full 3-act run | 1–2 for a skilled player (not 0, not a wall) |
| Boss kill time | Act 1 ~20–30 s, Act 2 ~30–45 s, Act 3 ~45–60 s |
| Level reached per act | Act 1 end ~5–6, Act 2 end ~10–12, Act 3 end ~15+ |
| Act 1 first-time clear | Achievable, but only after learning the boon picks |

Log every run with `scripts/run_log.gd` — deaths, boss times, level per act,
device, and stability notes — and compare against this table before retuning.

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
- `scripts/boons.gd` — boon pool, weapon upgrades/evolutions, level-up choices
- `scripts/run_log.gd` — run logging (deaths, boss times, level per act, device)
- `audio/sound_manager.gd` — placeholder SFX player (hits, pickups, level-up, boss cues) with mute
- `BUILD-PLAN.md` — the full App Builder plan for this update

## Open questions

- What Godot version is the existing project on, and is the Android failure an
  export, signing, or runtime crash?
- What is the intended difficulty target — expected deaths, boss kill time, and
  level reached per act for a skilled run?
- Which Android release model is intended — Play Store AAB, sideloaded APK, or
  itch.io — and which two phones and screen sizes are available to test?
