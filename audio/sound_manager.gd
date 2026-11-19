extends Node
## Placeholder SFX player: weapon hit, shard pickup, level-up, boss spawn,
## boss death — with a mute toggle. Placeholder effects are enough to test feel;
## drop real .wav/.ogg files into res://audio/ and assign them in _ready().

const SFX := {
	"hit": "res://audio/sfx_hit.wav",
	"pickup": "res://audio/sfx_pickup.wav",
	"level_up": "res://audio/sfx_level_up.wav",
	"boss_spawn": "res://audio/sfx_boss_spawn.wav",
	"boss_death": "res://audio/sfx_boss_death.wav",
}

var muted: bool = false
var players: Dictionary = {}

func _ready() -> void:
	muted = ProjectSettings.get_setting("ashen_saga/sound_muted", false)
	for key in SFX:
		var stream: AudioStream = load(SFX[key]) if ResourceLoader.exists(SFX[key]) else null
		if stream == null:
			# Placeholder: generated tone so the cue timing can still be tested
			# before real audio assets land.
			stream = _make_tone(key)
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.bus = "Master"
		add_child(player)
		players[key] = player

func _make_tone(key: String) -> AudioStreamWAV:
	# Short placeholder beep; pitch varies per cue so each is distinguishable.
	var freq := {"hit": 220.0, "pickup": 660.0, "level_up": 880.0, "boss_spawn": 110.0, "boss_death": 55.0}.get(key, 440.0)
	var sample_rate := 22050
	var length := 0.18 if key != "level_up" else 0.45
	var frames := int(sample_rate * length)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / sample_rate
		var envelope := 1.0 - (float(i) / frames)
		var sample := int(sin(TAU * freq * t) * 12000.0 * envelope)
		data.encode_s16(i * 2, sample)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav

func set_muted(value: bool) -> void:
	muted = value
	ProjectSettings.set_setting("ashen_saga/sound_muted", value)

func play_hit(weapon_name: String = "") -> void:
	_play("hit")

func play_pickup() -> void:
	_play("pickup")

func play_level_up() -> void:
	_play("level_up")

func play_boss_spawn() -> void:
	_play("boss_spawn")

func play_boss_death() -> void:
	_play("boss_death")

func _play(key: String) -> void:
	if muted:
		return
	var player: AudioStreamPlayer = players.get(key)
	if player != null:
		player.play()
