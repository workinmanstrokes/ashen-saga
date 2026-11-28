extends Node2D
## Per-act director: 3-minute timer, enemy mix, arena dressing, boss behaviour,
## and the saga beat between acts. Act identity lives here, not in the player.
##
## Tester update (VEX 4.0/10): difficulty is now restored per act instead of
## the easier web tuning — each act has its own spawn interval and enemy
## HP/damage multipliers, so Acts 2–3 are mechanically harder than Act 1,
## not just busier. There is no easy-mode flag anywhere in gameplay code:
## the Web preset exports the same tuned build as Android.
##
## Tester update (VEX 3.5/10): every act now states its boss damage as an
## explicit number (boss_damage, alongside boss_hp) so the difficulty target
## can be judged, and each boss gets a spoken intro (boss_intro, shown by
## show_boss_intro() when the boss spawns) so the Viking story is visible
## in-run instead of living only in the README.

const ACT_LENGTH_SECONDS := 180.0

const ACTS := {
	1: {
		"name": "Act I — The Burning Shore",
		"enemies": ["draugr_shambler", "draugr_shambler", "wolf"],
		"arena": "burned coastal village, ash-grey sand, broken longhouse beams",
		"boss": "Grimnir the Drowned Jarl",
		"boss_behaviour": "slow sweeping axe arcs, summons 2 shamblers at 50% HP",
		"boss_hp": 600.0,
		"boss_damage": 12.0,
		"boss_intro": "Grimnir the Drowned Jarl rises from the wrecked longhouse, his drowned crew shambling behind him. 'The Sunstone is mine, ash-hand — the sea keeps what it takes.'",
		"spawn_interval": 2.2,
		"enemy_hp_mult": 1.0,
		"enemy_damage_mult": 1.0,
		"intro_beat": "Nine winters after the burning, Eirik Ash-Hand sails for the shore where his brother fell. The Sunstone's light was last seen beyond the fjord.",
		"saga_beat": "The Sunstone's light was last seen beyond the fjord. Eirik buries his brother's axe and sails on.",
	},
	2: {
		"name": "Act II — The Pinewood Dark",
		"enemies": ["draugr_shambler", "wolf", "draugr_hunter", "wisp"],
		"arena": "black pine forest, fog, rune-carved standing stones",
		"boss": "Skadi's Hound, Fenrir's Pup",
		"boss_behaviour": "fast lunges with telegraphed pounces, splits into 2 pups at 50% HP",
		"boss_hp": 950.0,
		"boss_damage": 16.0,
		"boss_intro": "Skadi's Hound bursts from the pines — Fenrir's pup, all teeth and winter. It circles Eirik, waiting for the pounce.",
		"spawn_interval": 1.7,
		"enemy_hp_mult": 1.35,
		"enemy_damage_mult": 1.25,
		"intro_beat": "The pines close in like a shield-wall. Rune-stones whisper the Sunstone's name, and something hunts between the trees.",
		"saga_beat": "The stones whisper the Sunstone's name. Eirik carves his oath into the tallest pine and walks deeper.",
	},
	3: {
		"name": "Act III — The Sunstone Hall",
		"enemies": ["draugr_hunter", "wisp", "draugr_brute", "wolf"],
		"arena": "gold-lit burial hall, Sunstone glow on the walls, cracked pillars",
		"boss": "The Ashen King",
		"boss_behaviour": "rune-nova shockwaves in rings, summons brutes, enrages below 25% HP",
		"boss_hp": 1400.0,
		"boss_damage": 22.0,
		"boss_intro": "The Ashen King stands, the Sunstone burning in his crown. 'Nine winters I waited for a worthy death, Eirik Ash-Hand. Give me one.'",
		"spawn_interval": 1.3,
		"enemy_hp_mult": 1.8,
		"enemy_damage_mult": 1.5,
		"intro_beat": "Gold light bleeds from the burial hall. The Sunstone burns in the Ashen King's crown — one swing ends the hunt.",
		"saga_beat": "The Sunstone burns in the King's crown. Eirik raises his hammer — one swing ends the hunt.",
	},
}

var current_act: int = 1
var time_left: float = ACT_LENGTH_SECONDS
var boss_active: bool = false
var boss_spawned: bool = false
var run_active: bool = false
# Endless mode (meta-progression reward): unlocked by clearing all 3 acts.
# Replays the Act III mix with +25% enemy HP/damage per wave, no timer.
var endless_mode: bool = false
var endless_wave: int = 0

signal act_started(act: int, act_name: String)
signal boss_spawned(boss_name: String)
signal boss_intro_shown(text: String)
signal boss_defeated(boss_name: String, kill_seconds: float)
signal act_completed(act: int)
signal saga_beat_shown(text: String)
signal timer_changed(seconds_left: float)

@export var sound_manager: Node
@export var run_log: Node

func start_act(act: int) -> void:
	current_act = clampi(act, 1, 3)
	time_left = ACT_LENGTH_SECONDS
	boss_active = false
	boss_spawned = false
	endless_mode = false
	run_active = true
	act_started.emit(current_act, ACTS[current_act]["name"])
	show_intro_beat()
	print("Ashen Saga: %s — %s" % [ACTS[current_act]["name"], ACTS[current_act]["arena"]])

func start_endless() -> void:
	# Only called after a full 3-act clear (see run_log.endless_unlocked()).
	endless_mode = true
	endless_wave += 1
	current_act = 3
	time_left = ACT_LENGTH_SECONDS
	boss_active = false
	boss_spawned = false
	run_active = true
	act_started.emit(current_act, "Endless — Sunstone Hall, wave %d" % endless_wave)
	print("Ashen Saga: endless wave %d (enemy x%.2f)" % [endless_wave, endless_multiplier()])

func endless_multiplier() -> float:
	return 1.0 + 0.25 * float(maxi(endless_wave - 1, 0))

func _process(delta: float) -> void:
	if not run_active:
		return
	if endless_mode:
		return # No timer in endless mode; waves end only on death or quit.
	time_left -= delta
	timer_changed.emit(maxf(0.0, time_left))
	if time_left <= 0.0 and not boss_spawned:
		_spawn_boss()
	# Boss kill is reported by the arena via report_boss_defeated().

func _spawn_boss() -> void:
	boss_spawned = true
	boss_active = true
	var boss_name: String = ACTS[current_act]["boss"]
	boss_spawned.emit(boss_name)
	show_boss_intro()
	if sound_manager != null and sound_manager.has_method("play_boss_spawn"):
		sound_manager.play_boss_spawn()
	print("Ashen Saga: boss spawned — %s (%s, %d HP, %d damage)" % [boss_name, ACTS[current_act]["boss_behaviour"], int(boss_hp_for(current_act)), int(boss_damage_for(current_act))])

func report_boss_defeated(kill_seconds: float) -> void:
	if not boss_active:
		return
	boss_active = false
	run_active = false
	var boss_name: String = ACTS[current_act]["boss"]
	boss_defeated.emit(boss_name, kill_seconds)
	if sound_manager != null and sound_manager.has_method("play_boss_death"):
		sound_manager.play_boss_death()
	if run_log != null and run_log.has_method("record_boss_kill"):
		run_log.record_boss_kill(current_act, boss_name, kill_seconds)
	act_completed.emit(current_act)

func show_saga_beat() -> void:
	var beat: String = ACTS[current_act]["saga_beat"]
	saga_beat_shown.emit(beat)
	print("Saga beat: %s" % beat)

func show_intro_beat() -> void:
	# Act intro: the saga is told in-game before each act, not only in the README.
	var beat: String = ACTS[current_act]["intro_beat"]
	saga_beat_shown.emit(beat)
	print("Saga intro (Act %d): %s" % [current_act, beat])

func show_boss_intro() -> void:
	# Boss intro: the boss is named and speaks when it spawns, so the
	# Viking story is visible in the boss fight itself.
	var intro: String = ACTS[current_act]["boss_intro"]
	boss_intro_shown.emit(intro)
	print("Boss intro (Act %d): %s" % [current_act, intro])

func enemy_mix_for(act: int) -> Array:
	return ACTS.get(act, ACTS[1])["enemies"]

func arena_dressing_for(act: int) -> String:
	return ACTS.get(act, ACTS[1])["arena"]

func spawn_interval_for(act: int) -> float:
	return float(ACTS.get(act, ACTS[1])["spawn_interval"])

func enemy_hp_multiplier_for(act: int) -> float:
	var mult := float(ACTS.get(act, ACTS[1])["enemy_hp_mult"])
	if endless_mode:
		mult *= endless_multiplier()
	return mult

func enemy_damage_multiplier_for(act: int) -> float:
	var mult := float(ACTS.get(act, ACTS[1])["enemy_damage_mult"])
	if endless_mode:
		mult *= endless_multiplier()
	return mult

func boss_hp_for(act: int) -> float:
	var hp := float(ACTS.get(act, ACTS[1])["boss_hp"])
	if endless_mode:
		hp *= endless_multiplier()
	return hp

func boss_damage_for(act: int) -> float:
	var damage := float(ACTS.get(act, ACTS[1])["boss_damage"])
	if endless_mode:
		damage *= endless_multiplier()
	return damage

func boss_intro_for(act: int) -> String:
	return String(ACTS.get(act, ACTS[1])["boss_intro"])

func intro_beat_for(act: int) -> String:
	return String(ACTS.get(act, ACTS[1])["intro_beat"])
