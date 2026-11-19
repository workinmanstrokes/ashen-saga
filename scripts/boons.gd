extends Node
## Boon pool, weapon upgrades/evolutions, and level-up choices (pick 1 of 3).
## Combos meant to carry Acts 2–3 are named in BUILD-PLAN.md and flagged here.

const BOONS := [
	{"id": "heavy_hammer", "name": "Heavy Hammer", "desc": "+25% hammer damage", "weapon": "hammer", "rarity": "common"},
	{"id": "twin_axes", "name": "Twin Axes", "desc": "+1 throwing axe, -8% axe cooldown", "weapon": "axes", "rarity": "common"},
	{"id": "wide_nova", "name": "Wide Nova", "desc": "+30% rune nova radius", "weapon": "nova", "rarity": "common"},
	{"id": "swift_feet", "name": "Swift Feet", "desc": "+12% move speed", "weapon": "", "rarity": "common"},
	{"id": "thick_hide", "name": "Thick Hide", "desc": "+20 max HP, heal 20", "weapon": "", "rarity": "common"},
	{"id": "shard_magnet", "name": "Shard Magnet", "desc": "+50% shard pickup radius", "weapon": "", "rarity": "common"},
	{"id": "chain_lightning", "name": "Chain Lightning", "desc": "Rune nova chains to 2 extra enemies", "weapon": "nova", "rarity": "rare"},
	{"id": "rage_on_kill", "name": "Rage on Kill", "desc": "Kills grant +15% damage for 4s", "weapon": "", "rarity": "rare"},
	{"id": "stormcaller", "name": "Stormcaller", "desc": "EVOLUTION: nova strikes twice (needs nova lvl 3 + Chain Lightning)", "weapon": "nova", "rarity": "evolution"},
	{"id": "ashen_berserker", "name": "Ashen Berserker", "desc": "EVOLUTION: hammer hits splash (needs hammer lvl 3 + Rage on Kill)", "weapon": "hammer", "rarity": "evolution"},
	{"id": "skalds_hail", "name": "Skald's Hail", "desc": "EVOLUTION: axes rain from the sky (needs axes lvl 3 + Shard Magnet)", "weapon": "axes", "rarity": "evolution"},
	{"id": "second_wind", "name": "Second Wind", "desc": "Once per run: survive a fatal hit at 1 HP", "weapon": "", "rarity": "rare"},
]

const CARRY_COMBOS := {
	"Stormcaller": "maxed rune nova + Chain Lightning — clears Act 2 draugr packs",
	"Ashen Berserker": "maxed hammer + Rage on Kill — duels the Act 3 boss up close",
	"Skald's Hail": "maxed throwing axes + Shard Magnet — keeps XP flowing in Act 3",
}

var taken: Array[String] = []

signal boon_offered(choices: Array)
signal boon_chosen(boon_id: String)

func roll_choices(count: int = 3) -> Array:
	var pool: Array = BOONS.filter(func(b): return not taken.has(b["id"]))
	pool.shuffle()
	var choices: Array = pool.slice(0, mini(count, pool.size()))
	boon_offered.emit(choices)
	return choices

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
	if boon_id == "thick_hide" and player != null and player.has_method("heal"):
		player.heal(20.0)
	boon_chosen.emit(boon_id)
	print("Ashen Saga: boon chosen — %s (%s)" % [boon["name"], boon["rarity"]])

func reset_run() -> void:
	taken.clear()
