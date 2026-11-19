extends Node
## Run logging: deaths, boss times, level reached per act, difficulty target,
## device and stability notes. Written to user:// so it survives on the phone
## and can be read back after a test session.

const LOG_PATH := "user://ashen_saga_run_log.json"

# Difficulty target (README.md): skilled run = 1–2 deaths per full run;
# boss kill ~20–30s (Act 1), ~30–45s (Act 2), ~45–60s (Act 3);
# level ~5–6 / ~10–12 / ~15+ at each act end.
const TARGET_DEATHS_PER_RUN := Vector2i(1, 2)
const TARGET_BOSS_SECONDS := {1: Vector2(20.0, 30.0), 2: Vector2(30.0, 45.0), 3: Vector2(45.0, 60.0)}
const TARGET_LEVEL_PER_ACT := {1: 6, 2: 12, 3: 15}

var current_run: Dictionary = {}
var history: Array = []

func _ready() -> void:
	_load_history()

func start_run(device_info: String = "") -> void:
	current_run = {
		"started_at": Time.get_datetime_string_from_system(),
		"device": device_info if device_info != "" else "%s %s" % [OS.get_name(), OS.get_model_name()],
		"deaths": 0,
		"boss_times": {},
		"level_per_act": {},
		"stability_notes": "",
	}
	print("Ashen Saga run started on %s" % current_run["device"])

func record_death(act: int) -> void:
	if current_run.is_empty():
		return
	current_run["deaths"] = int(current_run["deaths"]) + 1
	print("Ashen Saga: death in Act %d (total %d)" % [act, current_run["deaths"]])

func record_boss_kill(act: int, boss_name: String, kill_seconds: float) -> void:
	if current_run.is_empty():
		return
	current_run["boss_times"][str(act)] = {"boss": boss_name, "seconds": kill_seconds}
	print("Ashen Saga: boss '%s' killed in %.1fs (Act %d)" % [boss_name, kill_seconds, act])

func record_act_level(act: int, level: int) -> void:
	if current_run.is_empty():
		return
	current_run["level_per_act"][str(act)] = level

func note_stability(note: String) -> void:
	if current_run.is_empty():
		return
	current_run["stability_notes"] = note

func end_run(finished: bool) -> Dictionary:
	if current_run.is_empty():
		return {}
	current_run["finished"] = finished
	current_run["ended_at"] = Time.get_datetime_string_from_system()
	current_run["within_death_target"] = int(current_run["deaths"]) >= TARGET_DEATHS_PER_RUN.x and int(current_run["deaths"]) <= TARGET_DEATHS_PER_RUN.y
	history.append(current_run.duplicate(true))
	_save_history()
	var finished_run: Dictionary = current_run
	current_run = {}
	return finished_run

func summary_text(run: Dictionary) -> String:
	return "deaths %d | boss times %s | level per act %s | device %s" % [
		run.get("deaths", 0), run.get("boss_times", {}), run.get("level_per_act", {}), run.get("device", "?")]

func _load_history() -> void:
	if not FileAccess.file_exists(LOG_PATH):
		return
	var file := FileAccess.open(LOG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		history = parsed

func _save_history() -> void:
	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Ashen Saga: could not write run log to %s" % LOG_PATH)
		return
	file.store_string(JSON.stringify(history, "\t"))
