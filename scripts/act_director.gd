extends Node2D
## Per-act director: 3-minute timer, enemy mix, arena dressing, boss behaviour,
## and the saga beat between acts. Act identity lives here, not in the player.

const ACT_LENGTH_SECONDS := 180.0

const ACTS := {
	1: {
		"name": "Act I — The Burning Shore",
		"enemies": ["draugr_shambler", "draugr_shambler", "wolf"],
		"arena": "burned coastal village, ash-grey sand, broken longhouse beams",
		"boss": "Grimnir the Drowned Jarl",
		"boss_behaviour": "slow sweeping axe arcs, summons 2 shamblers at 50% HP",
		"saga_beat": "The Sunstone's light was last seen beyond the fjord. Eirik buries his brother's axe and sails on.",
	},
	2: {
		"name": "Act II — The Pinewood Dark",
		"enemies": ["draugr_shambler", "wolf", "draugr_hunter", "wisp"],
		"arena": "black pine forest, fog, rune-carved standing stones",
		"boss": "Skadi's Hound, Fenrir's Pup",
		"boss_behaviour": "fast lunges with telegraphed pounces, splits into 2 pups at 50% HP",
		"saga_beat": "The stones whisper the Sunstone's name. Eirik carves his oath into the tallest pine and walks deeper.",
	},
	3: {
		"name": "Act III — The Sunstone Hall",
		"enemies": ["draugr_hunter", "wisp", "draugr_brute", "wolf"],
		"arena": "gold-lit burial hall, Sunstone glow on the walls, cracked pillars",
		"boss": "The Ashen King",
		"boss_behaviour": "rune-nova shockwaves in rings, summons brutes, enrages below 25% HP",
		"saga_beat": "The Sunstone burns in the King's crown. Eirik raises his hammer — one swing ends the hunt.",
	},
}

var current_act: int = 1
var time_left: float = ACT_LENGTH_SECONDS
var boss_active: bool = false
var boss_spawned: bool = false
var run_active: bool = false

signal act_started(act: int, act_name: String)
signal boss_spawned(boss_name: String)
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
	run_active = true
	act_started.emit(current_act, ACTS[current_act]["name"])
	print("Ashen Saga: %s — %s" % [ACTS[current_act]["name"], ACTS[current_act]["arena"]])

func _process(delta: float) -> void:
	if not run_active:
		return
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
	if sound_manager != null and sound_manager.has_method("play_boss_spawn"):
		sound_manager.play_boss_spawn()
	print("Ashen Saga: boss spawned — %s (%s)" % [boss_name, ACTS[current_act]["boss_behaviour"]])

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

func enemy_mix_for(act: int) -> Array:
	return ACTS.get(act, ACTS[1])["enemies"]

func arena_dressing_for(act: int) -> String:
	return ACTS.get(act, ACTS[1])["arena"]
