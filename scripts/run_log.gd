extends Node
## Run logging: deaths, boss times, level reached per act, difficulty target,
## device and stability notes. Written to user:// so it survives on the phone
## and can be read back after a test session.
##
## Tester update (VEX 4.0/10): meta-progression — the 9-minute run now banks
## Sunstone shards (1 per boss kill) and persists a best-act / total-runs /
## full-clear record across runs. Clearing all 3 acts unlocks Endless mode
## (see act_director.start_endless()), which is the replay hook the tester
## flagged as missing.
##
## Tester update (VEX 3.5/10): the boss gate — a full 3-act clear only
## counts as proving the bosses gate progress once at least one failed run
## has been logged first (boss_gate_proven()). Failed runs are counted in
## meta ("failed_runs") so the playtest log can show the gate was met
## instead of the run being cleared on the first try with the easy tuning.
##
## Tester update (VEX 3.5/10, difficulty red flag): the difficulty-evidence
## gate — the earlier retune was judged easier without rebalancing evidence.
## A logged run now records whether it met the whole difficulty target
## (meets_difficulty_target: 1–2 deaths, every boss kill inside its target
## window, every act level at or above its target), and the tuning in
## act_director.gd is frozen until difficulty_evidence_met() is true:
## 3 logged full runs inside the target. No retune ships on a feeling —
## log runs first, then retune against the evidence.

const LOG_PATH := "user://ashen_saga_run_log.json"
const META_PATH := "user://ashen_saga_meta.json"

# Difficulty target (README.md): skilled run = 1–2 deaths per full run;
# boss kill ~20–30s (Act 1), ~30–45s (Act 2), ~45–60s (Act 3);
# level ~5–6 / ~10–12 / ~15+ at each act end.
const TARGET_DEATHS_PER_RUN := Vector2i(1, 2)
const TARGET_BOSS_SECONDS := {1: Vector2(20.0, 30.0), 2: Vector2(30.0, 45.0), 3: Vector2(45.0, 60.0)}
const TARGET_LEVEL_PER_ACT := {1: 6, 2: 12, 3: 15}
# Boss gate: at least this many failed runs must be logged before a full
# clear counts as proof the bosses gate progress.
const REQUIRED_FAILED_RUNS := 1
# Difficulty-evidence gate: this many logged full runs inside the difficulty
# target are required before the tuning in act_director.gd may be retuned.
const REQUIRED_EVIDENCE_RUNS := 3

var current_run: Dictionary = {}
var history: Array = []
# Meta-progression, persisted across runs: shards banked, best act reached,
# total runs, full 3-act clears, failed runs, and whether Endless mode is unlocked.
var meta: Dictionary = {
	"shards_banked": 0,
	"best_act": 0,
	"total_runs": 0,
	"full_clears": 0,
	"failed_runs": 0,
	"endless_unlocked": false,
}

func _ready() -> void:
	_load_history()
	_load_meta()

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
	# Meta-progression: every boss kill banks 1 Sunstone shard for the next run.
	meta["shards_banked"] = int(meta["shards_banked"]) + 1
	meta["best_act"] = maxi(int(meta["best_act"]), act)
	_save_meta()
	print("Ashen Saga: boss '%s' killed in %.1fs (Act %d) — shard banked (%d total)" % [boss_name, kill_seconds, act, int(meta["shards_banked"])])

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
	current_run["within_boss_targets"] = _boss_times_within_target(current_run)
	current_run["within_level_targets"] = _levels_within_target(current_run)
	current_run["meets_difficulty_target"] = bool(current_run["within_death_target"]) and bool(current_run["within_boss_targets"]) and bool(current_run["within_level_targets"])
	meta["total_runs"] = int(meta["total_runs"]) + 1
	if finished and int(current_run["boss_times"].size()) >= 3:
		# Full 3-act clear: unlocks Endless mode (the replay hook).
		meta["full_clears"] = int(meta["full_clears"]) + 1
		meta["best_act"] = 3
		meta["endless_unlocked"] = true
	if not finished:
		# A failed run: the boss-gate evidence the tester asked for.
		meta["failed_runs"] = int(meta.get("failed_runs", 0)) + 1
	_save_meta()
	history.append(current_run.duplicate(true))
	_save_history()
	print("Ashen Saga: run ended (finished=%s) — meets difficulty target: %s (evidence %d/%d)" % [finished, bool(current_run["meets_difficulty_target"]), evidence_runs(), REQUIRED_EVIDENCE_RUNS])
	var finished_run: Dictionary = current_run
	current_run = {}
	return finished_run

func endless_unlocked() -> bool:
	return bool(meta["endless_unlocked"])

func shards_banked() -> int:
	return int(meta["shards_banked"])

func failed_runs() -> int:
	return int(meta.get("failed_runs", 0))

func boss_gate_proven() -> bool:
	# True once at least one failed run is on record: the bosses can only
	# be said to gate progress if somebody has failed against them first.
	# Check this in the phone-test log before calling a full clear a pass.
	return failed_runs() >= REQUIRED_FAILED_RUNS

func run_meets_difficulty_target(run: Dictionary) -> bool:
	# A logged run counts as rebalancing evidence only if it sits inside the
	# whole difficulty target: 1–2 deaths, every boss kill inside its target
	# window, and every act level at or above its target. A stored run that
	# was already judged keeps its recorded flag.
	if run.has("meets_difficulty_target"):
		return bool(run["meets_difficulty_target"])
	var deaths: int = int(run.get("deaths", 0))
	if deaths < TARGET_DEATHS_PER_RUN.x or deaths > TARGET_DEATHS_PER_RUN.y:
		return false
	return _boss_times_within_target(run) and _levels_within_target(run)

func _boss_times_within_target(run: Dictionary) -> bool:
	var boss_times: Dictionary = run.get("boss_times", {})
	if boss_times.is_empty():
		return false
	for act_key in boss_times:
		var act: int = int(act_key)
		if not TARGET_BOSS_SECONDS.has(act):
			return false
		var window: Vector2 = TARGET_BOSS_SECONDS[act]
		var seconds: float = float(boss_times[act_key].get("seconds", 0.0))
		if seconds < window.x or seconds > window.y:
			return false
	return true

func _levels_within_target(run: Dictionary) -> bool:
	var levels: Dictionary = run.get("level_per_act", {})
	if levels.is_empty():
		return false
	for act_key in levels:
		var act: int = int(act_key)
		if not TARGET_LEVEL_PER_ACT.has(act):
			return false
		if int(levels[act_key]) < int(TARGET_LEVEL_PER_ACT[act]):
			return false
	return true

func evidence_runs() -> int:
	# Logged finished full 3-act runs that met the difficulty target — the
	# rebalancing evidence for the current tuning. A retune with no evidence
	# behind it is exactly the red flag the tester raised.
	var count := 0
	for run in history:
		if bool(run.get("finished", false)) and int(run.get("boss_times", {}).size()) >= 3 and run_meets_difficulty_target(run):
			count += 1
	return count

func difficulty_evidence_met() -> bool:
	# True once enough logged runs inside the target exist to call the
	# current difficulty evidence-backed. Until then the tuning in
	# act_director.gd is frozen: do not retune easier (or harder) on a
	# feeling — log runs first, then retune against the evidence.
	return evidence_runs() >= REQUIRED_EVIDENCE_RUNS

func meta_summary() -> String:
	return "shards %d | best act %d | runs %d | full clears %d | failed runs %d | difficulty evidence %d/%d | endless %s" % [
		int(meta["shards_banked"]), int(meta["best_act"]), int(meta["total_runs"]),
		int(meta["full_clears"]), failed_runs(), evidence_runs(), REQUIRED_EVIDENCE_RUNS,
		"unlocked" if bool(meta["endless_unlocked"]) else "locked"]

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

func _load_meta() -> void:
	if not FileAccess.file_exists(META_PATH):
		return
	var file := FileAccess.open(META_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in meta:
			if parsed.has(key):
				meta[key] = parsed[key]

func _save_meta() -> void:
	var file := FileAccess.open(META_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Ashen Saga: could not write meta-progression to %s" % META_PATH)
		return
	file.store_string(JSON.stringify(meta, "\t"))
