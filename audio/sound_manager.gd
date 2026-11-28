extends Node
## Placeholder SFX player: weapon hit, shard pickup, level-up, boss spawn,
## boss death — with a mute toggle. Placeholder effects are enough to test feel;
## drop real .wav/.ogg files into res://audio/ and assign them in _ready().
##
## Tester update (VEX 4.0/10): weapon hits are now distinguishable — the
## hammer thuds low, axes cut mid, and the rune nova rings high — so the
## three auto-weapons give different audio feedback instead of one beep.
##
## Tester update (VEX 3.5/10): a simple looping music track — a low drone
## with a slow A-minor melody, generated in code like the SFX so the Viking
## atmosphere is testable before real audio lands. start_music() /
## stop_music() control it; the mute toggle silences music and SFX together.
## A real res://audio/music_loop.wav (or .ogg) replaces the generated loop
## automatically when it exists.

const SFX := {
	"hit": "res://audio/sfx_hit.wav",
	"pickup": "res://audio/sfx_pickup.wav",
	"level_up": "res://audio/sfx_level_up.wav",
	"boss_spawn": "res://audio/sfx_boss_spawn.wav",
	"boss_death": "res://audio/sfx_boss_death.wav",
}

const MUSIC_PATH := "res://audio/music_loop.wav"

# Per-weapon hit pitch: hammer low, axes mid, nova high.
const HIT_PITCH := {"hammer": 0.8, "axes": 1.0, "nova": 1.25}

var muted: bool = false
var players: Dictionary = {}
var music_player: AudioStreamPlayer

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
	var music_stream: AudioStream = load(MUSIC_PATH) if ResourceLoader.exists(MUSIC_PATH) else null
	if music_stream == null:
		music_stream = _make_music_loop()
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_stream
	music_player.bus = "Master"
	music_player.volume_db = -12.0
	add_child(music_player)
	if not muted:
		start_music()

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

func _make_music_loop() -> AudioStreamWAV:
	# 8-second looping placeholder: a low A drone under a slow A-minor
	# melody (one note per second), with a short fade at the loop seam so
	# it repeats without a click. Replace with a real track when one exists.
	var sample_rate := 22050
	var length := 8.0
	var frames := int(sample_rate * length)
	var notes := [220.0, 261.63, 329.63, 293.66, 220.0, 329.63, 196.0, 246.94]
	var note_len := frames / notes.size()
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / sample_rate
		var note_idx := mini(i / note_len, notes.size() - 1)
		var freq: float = notes[note_idx]
		var note_t := float(i % note_len) / float(note_len)
		var envelope := 1.0 - 0.5 * note_t
		var seam := 1.0
		if i < 512:
			seam = float(i) / 512.0
		elif i >= frames - 512:
			seam = float(frames - i) / 512.0
		var value := (sin(TAU * 110.0 * t) * 0.35 + sin(TAU * freq * t) * 0.55 * envelope) * 12000.0 * seam
		data.encode_s16(i * 2, int(value))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = frames
	return wav

func set_muted(value: bool) -> void:
	muted = value
	ProjectSettings.set_setting("ashen_saga/sound_muted", value)
	if muted:
		stop_music()
	else:
		start_music()

func start_music() -> void:
	if muted:
		return
	if music_player != null and not music_player.playing:
		music_player.play()

func stop_music() -> void:
	if music_player != null and music_player.playing:
		music_player.stop()

func play_hit(weapon_name: String = "") -> void:
	var player: AudioStreamPlayer = players.get("hit")
	if player != null:
		player.pitch_scale = float(HIT_PITCH.get(weapon_name, 1.0))
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
