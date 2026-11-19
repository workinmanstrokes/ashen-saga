# Ashen Saga: Android Fix Update — Build Plan

- **Name:** Ashen Saga: Android Fix Update
- **Kind:** game (update to an existing project)
- **Platform:** Android
- **Category:** Survivors-like action RPG
- **Tagline:** First make it open on a real phone — then make the Sunstone hunt hard, loud, and worth replaying.
- **Stack:** Godot with GDScript, exported to Android
- **Tester score on current build:** 4.0/10 (grade D)

## Summary

Next update for the existing Viking Age survivors RPG Ashen Saga, where Eirik
Ash-Hand hunts the Sunstone across three 3-minute acts, each ending in a boss,
using auto-attack weapons, XP runestone shards, and choose-1-of-3 boons. The
full story and web build already play through, but a tester scored it 4.0/10
(D): the Godot Android build would not open on a phone, the web tuning is
easier than intended, and there is no sound. This plan follows the tester's
order strictly: prove the Android build on one real phone before tuning
anything, restore the intended difficulty and log full 3-act runs, add five
placeholder sound effects, make each act visually and mechanically distinct
with saga beats, widen boons and weapon evolutions, and only then choose a
release model and test on two phones of different sizes.

## Features

1. Godot Android build that installs, opens, and completes Act 1 on one real
   phone with a recorded install, first-run, and stability log
2. Full 3-act run (3 minutes + boss per act) at the restored intended
   difficulty, not the easier web tuning
3. Run logging for deaths, boss kill times, and level reached per act against
   a stated difficulty target
4. Minimum viable sound: weapon hit, shard pickup, level-up, boss spawn, and
   boss death placeholder SFX with a mute toggle
5. Three distinct acts: different enemy mix, arena dressing, and boss
   behaviour per act
6. Short in-game saga beats between acts advancing the Sunstone hunt
7. Expanded boons, weapon upgrades, and evolutions, with named combinations
   intended to carry Acts 2–3
8. Auto-attack hammer, throwing axes, and rune nova, XP runestone shards,
   choose-1-of-3 boons on level-up, and touch controls sized for phones

## Screens

- Main menu / title
- Act intro and saga beat interstitial
- Gameplay arena with HUD (health, XP, timer, act, boss bar)
- Level-up boon choice (1 of 3)
- Pause and settings (sound mute, restart, quit)
- Boss intro and boss fight
- Act complete / run summary (deaths, boss time, level)
- Game over and Sunstone ending

## Entities

- Player (Eirik Ash-Hand: HP, level, XP, movement, equipped weapons)
- Weapon (hammer, throwing axes, rune nova: level, damage, cooldown, evolution)
- Boon (level-up choice: effect, rarity, stacking)
- Enemy (type, act, HP, speed, damage, spawn wave)
- Boss (per-act behaviour, HP, attack pattern, spawn/kill time)
- Runestone shard (XP pickup value and drop/magnet rules)
- Act (number, 3-minute timer, enemy mix, arena dressing, boss)
- Run log (deaths, boss times, level reached per act, difficulty target, device)
- Settings / save (sound on/off, best act reached, run history)

## Milestones

1. Prove the Godot Android build on one real phone: clean export, install,
   first run, Act 1 completion, and stability log — no tuning until this passes
2. Restore the intended difficulty and instrument full 3-act runs, logging
   deaths, boss times, and level reached per act against an explicit
   difficulty target
3. Add minimum viable sound — weapon hit, shard pickup, level-up, boss spawn,
   and boss death placeholder SFX with mute — and verify it on the phone
4. Make each act distinct: per-act enemy mix, arena dressing, and boss
   behaviour, plus saga beats between acts
5. Widen build choices: add boons, weapon upgrades, and evolutions, and
   document which combinations are meant to carry Acts 2–3
6. Decide the Android release model and test it on at least two real phones
   with different screen sizes before calling it an Android build

## Boon / evolution combos meant to carry Acts 2–3

- **Stormcaller:** maxed rune nova + chain-lightning boon — clears Act 2 draugr packs
- **Ashen Berserker:** maxed hammer + rage-on-kill boon — duels the Act 3 boss up close
- **Skald's Hail:** maxed throwing axes + shard-magnet boon — keeps XP flowing in Act 3
  (Confirm or replace these after the first difficulty-logged runs.)

## First step

Do a clean Godot Android export from the existing project and install it on one
real phone, recording whether it opens and completes Act 1 before changing any
gameplay.
