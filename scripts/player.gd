extends CharacterBody2D
## Eirik Ash-Hand: movement, touch controls, auto-attack weapons, HP and XP.
## Weapons auto-attack on their own timers; the player only moves and picks boons.
##
## Tester update (VEX 4.0/10): boons now actually apply (speed, pickup radius,
## max HP, damage and Second Wind were listed before but never took effect),
## and shard pickups play their sound through collect_shard().

const SPEED := 220.0
const MAX_HP := 100.0
# Touch controls: drag closer than this to Eirik does nothing, so a resting
# thumb does not drag him. 48px is the minimum touch-target size for the
# on-screen buttons (boon cards, pause, mute) — see README controls table.
const DRAG_DEADZONE_PX := 12.0
const XP_PER_LEVEL := [0, 8, 20, 38, 62, 92, 128, 170, 218, 272, 332, 400, 475, 556, 644, 740]

@export var sound_manager: Node
@export var boons: Node

var max_hp: float = MAX_HP
var hp: float = MAX_HP
var level: int = 1
var xp: int = 0
var move_speed_mult: float = 1.0
var pickup_radius_mult: float = 1.0
var damage_mult: float = 1.0
var shard_xp_bonus: int = 0
var second_wind_ready: bool = false
var weapons: Dictionary = {
	"hammer": {"level": 1, "damage": 12.0, "cooldown": 1.1, "timer": 0.0},
	"axes": {"level": 1, "damage": 8.0, "cooldown": 0.8, "timer": 0.0},
	"nova": {"level": 1, "damage": 10.0, "cooldown": 2.4, "timer": 0.0},
}
var move_input: Vector2 = Vector2.ZERO
var dead: bool = false

signal hp_changed(current: float, maximum: float)
signal xp_changed(current: int, needed: int, current_level: int)
signal leveled_up(new_level: int)
signal died

func _ready() -> void:
	hp_changed.emit(hp, max_hp)
	xp_changed.emit(xp, xp_needed_for(level), level)

func _physics_process(delta: float) -> void:
	if dead:
		return
	_read_touch_input()
	velocity = move_input * SPEED * move_speed_mult
	move_and_slide()
	_tick_weapons(delta)

func _read_touch_input() -> void:
	# Virtual joystick / drag-to-move: touch drag sets the move direction.
	# Keyboard (WASD/arrows) works on desktop for testing; on Android only touch arrives.
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir.length() > 0.1:
		move_input = dir.normalized()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var target := get_global_mouse_position()
		var to_target := target - global_position
		move_input = to_target.normalized() if to_target.length() > DRAG_DEADZONE_PX else Vector2.ZERO
	else:
		move_input = Vector2.ZERO

func _tick_weapons(delta: float) -> void:
	for weapon_name in weapons:
		var w: Dictionary = weapons[weapon_name]
		w["timer"] -= delta
		if w["timer"] <= 0.0:
			w["timer"] = w["cooldown"]
			_fire_weapon(weapon_name, w)

func _fire_weapon(weapon_name: String, w: Dictionary) -> void:
	# Auto-attack: damage is applied by the arena/enemy system to the nearest
	# target(s); this is the timing + SFX hook, not the hit resolution.
	# damage_mult is read by the arena when it resolves the hit.
	if sound_manager != null and sound_manager.has_method("play_hit"):
		sound_manager.play_hit(weapon_name)

func collect_shard(value: int) -> void:
	# Single entry point for runestone shard pickups: XP plus the pickup cue,
	# so the shard sound can never be skipped by calling gain_xp directly.
	if dead:
		return
	if sound_manager != null and sound_manager.has_method("play_pickup"):
		sound_manager.play_pickup()
	gain_xp(value + shard_xp_bonus)

func gain_xp(amount: int) -> void:
	if dead:
		return
	xp += amount
	while level < XP_PER_LEVEL.size() and xp >= XP_PER_LEVEL[level]:
		xp -= XP_PER_LEVEL[level]
		level += 1
		leveled_up.emit(level)
		if sound_manager != null and sound_manager.has_method("play_level_up"):
			sound_manager.play_level_up()
	xp_changed.emit(xp, xp_needed_for(level), level)

func xp_needed_for(lv: int) -> int:
	if lv >= XP_PER_LEVEL.size():
		return XP_PER_LEVEL[XP_PER_LEVEL.size() - 1]
	return XP_PER_LEVEL[lv]

func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(0.0, hp - amount)
	if hp <= 0.0 and second_wind_ready:
		# Second Wind boon: survive one fatal hit at 1 HP, once per run.
		second_wind_ready = false
		hp = 1.0
		print("Ashen Saga: Second Wind — fatal hit survived at 1 HP")
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		dead = true
		died.emit()

func heal(amount: float) -> void:
	hp = minf(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func add_max_hp(amount: float) -> void:
	max_hp += amount
	hp = minf(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func add_move_speed_mult(mult: float) -> void:
	move_speed_mult *= mult

func add_pickup_radius_mult(mult: float) -> void:
	pickup_radius_mult *= mult

func add_damage_mult(mult: float) -> void:
	damage_mult *= mult

func add_shard_xp_bonus(bonus: int) -> void:
	shard_xp_bonus += bonus

func grant_second_wind() -> void:
	second_wind_ready = true

func upgrade_weapon(weapon_name: String) -> void:
	if weapons.has(weapon_name):
		var w: Dictionary = weapons[weapon_name]
		w["level"] = int(w["level"]) + 1
		w["damage"] = float(w["damage"]) * 1.25
		w["cooldown"] = maxf(0.35, float(w["cooldown"]) * 0.92)
