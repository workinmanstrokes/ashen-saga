extends Node
## Boon pool, weapon upgrades/evolutions, and level-up choices (pick 1 of 3).
## Combos meant to carry Acts 2–3 are named in BUILD-PLAN.md and flagged here.
##
## Tester update (VEX 4.0/10): the pool grows from 12 to 19 boons plus a 4th
## evolution, and evolution boons are now gated — an evolution is only offered
## once its prerequisite boon has been taken, so the "needs X" text is a real
## rule instead of flavour. Boon effects are applied in choose() via the
## player methods (previously several listed effects never took effect).

const BOONS := [
	{"id": "heavy_hammer", "name": "Heavy Hammer", "desc": "+25% hammer damage", "weapon": "hammer", "rarity": "common"},
	{"id": "sharpened_edge", "name": "Sharpened Edge", "desc": "+25% hammer damage, faster swing", "weapon": "hammer", "rarity": "common"},
	{"id": "twin_axes", "name": "Twin Axes", "desc": "+1 throwing axe, -8% axe cooldown", "weapon": "axes", "rarity": "common"},
	{"id": "whirling_axes", "name": "Whirling Axes", "desc": "+25% axe damage, axes return to Eirik", "weapon": "axes", "rarity": "rare"},
	{"id": "wide_nova", "name": "Wide Nova", "desc": "+30% rune nova radius", "weapon": "nova", "rarity": "common"},
	{"id": "rune_overload", "name": "Rune Overload", "desc": "+25% rune nova damage, -8% nova cooldown", "weapon": "nova", "rarity": "rare"},
	{"id": "swift_feet", "name": "Swift Feet", "desc": "+12% move speed", "weapon": "", "rarity": "common"},
	{"id": "thick_hide", "name": "Thick Hide", "desc": "+20 max HP, heal 20", "weapon": "", "rarity": "common"},
	{"id": "oathbound", "name": "Oathbound", "desc": "+25 max HP, heal 25", "weapon": "", "rarity": "rare"},
	{"id": "shard_magnet", "name": "Shard Magnet", "desc": "+50% shard pickup radius", "weapon": "", "rarity": "common"},
	{"id": "sunstone_greed", "name": "Sunstone Greed", "desc": "+50% shard pickup radius, shards worth +1 XP", "weapon": "", "rarity": "rare"},
	{"id": "chain_lightning", "name": "Chain Lightning", "desc": "Rune nova chains to 2 extra enemies", "weapon": "nova", "rarity": "rare"},
	{"id": "rage_on_kill", "name": "Rage on Kill", "desc": "+15% damage (a kill-fuelled battle rage)", "weapon": "", "rarity": "rare"},
	{"id": "blood_price", "name": "Blood Price", "desc": "+20% damage, -10 max HP — the Sunstone demands payment", "weapon": "", "rarity": "rare"},
	{"id": "stormcaller", "name": "Stormcaller", "desc": "EVOLUTION: nova strikes twice (needs nova lvl 3 + Chain Lightning)", "weapon": "nova", "rarity": "evolution", "requires": "chain_lightning"},
	{"id": "ashen_berserker", "name": "Ashen Berserker", "desc": "EVOLUTION: hammer hits splash (needs hammer lvl 3 + Rage on Kill)", "weapon": "hammer", "rarity": "evolution", "requires": "rage_on_kill"},
	{"id": "skalds_hail", "name": "Skald's Hail", "desc": "EVOLUTION: axes rain from the sky (needs axes lvl 3 + Shard Magnet)", "weapon": "axes", "rarity": "evolution", "requires": "shard_magnet"},
	{"id": "sunstone_herald", "name": "Sunstone Herald", "desc": "EVOLUTION: hammer and nova strike together (needs Stormcaller)", "weapon": "nova", "rarity": "evolution", "requires": "stormcaller"},
	{"id": "second_wind", "name": "Second Wind", "desc": "Once per run: survive a fatal hit at 1 HP", "weapon": "", "rarity": "rare"},
]

const CARRY_COMBOS := {
	"Stormcaller": "maxed rune nova + Chain Lightning — clears Act 2 draugr packs",
	"Ashen Berserker": "maxed hammer + Rage on Kill — duels the Act 3 boss up close",
	"Skald's Hail": "maxed throwing axes + Shard Magnet — keeps XP flowing in Act 3",
	"Sunstone Herald": "Stormcaller + Sunstone Herald — the Act 3 boss-killer combo",
}

var taken: Array[String] = []

signal boon_offered(choices: Array)
signal boon_chosen(boon_id: String)

func roll_choices(count: int = 3) -> Array:
	var pool: Array = BOONS.filter(func(b): return _is_offerable(b))
	pool.shuffle()
	var choices: Array = pool.slice(0, mini(count, pool.size()))
	boon_offered.emit(choices)
	return choices

func _is_offerable(boon: Dictionary) -> bool:
	if taken.has(boon["id"]):
		return false
	# Evolutions are only offered once their prerequisite boon was taken.
	var required: String = String(boon.get("requires", ""))
	if required != "" and not taken.has(required):
		return false
	return true

func choose(boon_id: String, player: Node) -> void:
	var boon: Dictionary = {}
	for b in BOONS:
		if b["id"] == boon_id:
			boon = b
			break
	if boon.is_empty():
		push_warning("Ashen Saga: unknown boon '%s'" % boon_id)
		return
	taken.append(boon_id)
	if boon["weapon"] != "" and player != null and player.has_method("upgrade_weapon"):
		player.upgrade_weapon(boon["weapon"])
	if player != null:
		match boon_id:
			"swift_feet":
				player.add_move_speed_mult(1.12)
			"thick_hide":
				player.add_max_hp(20.0)
				player.heal(20.0)
			"oathbound":
				player.add_max_hp(25.0)
				player.heal(25.0)
			"shard_magnet":
				player.add_pickup_radius_mult(1.5)
			"sunstone_greed":
				player.add_pickup_radius_mult(1.5)
				player.add_shard_xp_bonus(1)
			"rage_on_kill":
				player.add_damage_mult(1.15)
			"blood_price":
				player.add_damage_mult(1.2)
				player.add_max_hp(-10.0)
			"second_wind":
				player.grant_second_wind()
	boon_chosen.emit(boon_id)
	print("Ashen Saga: boon chosen — %s (%s)" % [boon["name"], boon["rarity"]])

func reset_run() -> void:
	taken.clear()
