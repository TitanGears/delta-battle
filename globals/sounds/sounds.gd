extends Node

var sounds: Dictionary[String, AudioStreamPlayer] = {}
var music: Dictionary[String, AudioStreamPlayer] = {}

var current_song := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var sound_files := get_files_recursive("res://globals/sounds/sound_effects")
	if !sound_files.is_empty():
		for file: String in sound_files:
			if file.ends_with(".gitignore") :
				continue
			var audio_player := AudioStreamPlayer.new()
			audio_player.name = file.get_file().trim_suffix("." + file.get_extension())
			audio_player.stream = load(file)
			add_child(audio_player)
			sounds.set(audio_player.name, audio_player)
	
	var music_files := get_files_recursive("res://globals/sounds/music")
	if !music_files.is_empty():
		for file: String in music_files:
			if file.ends_with(".gitignore") :
				continue
			var audio_player := AudioStreamPlayer.new()
			audio_player.name = file.get_file().trim_suffix("." + file.get_extension())
			audio_player.stream = load(file)
			add_child(audio_player)
			music.set(audio_player.name, audio_player)

func get_files_recursive(p_directory: String) -> PackedStringArray:
	var files := PackedStringArray()
	for dir: String in DirAccess.get_directories_at(p_directory):
		files.append_array(get_files_recursive(p_directory + "/" + dir))
	for file: String in DirAccess.get_files_at(p_directory):
		if OS.get_name() == "Web":
			file = file.trim_suffix(".import")
		if file.get_extension() != "import":
			files.append(p_directory + "/" + file)
	return files

func play(p_sound: String, p_volume := 1.0) -> void:
	if !sounds.has(p_sound):
		#printerr("Error in sounds.gd: Attempt to play sound, \"" + p_sound + "\", but no such sound exists.")
		return
	var audio_player := sounds[p_sound]
	audio_player.volume_linear = p_volume
	audio_player.play()

func play_looped(p_sound : String, p_volume := 1.0) -> void :
	if !sounds.has(p_sound) :
		#printerr("Error in sounds.gd: Attempt to play sound, \"" + p_sound + "\", but no such sound exists.")
		return
	var audio_player := sounds[p_sound]
	var stream := audio_player.stream
	if stream is AudioStreamWAV :
		if stream.loop_mode == AudioStreamWAV.LOOP_DISABLED :
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			# N'oublie pas d'importer en précisant si ça loop.
			#stream.loop_end = stream.data.size() / (2 if stream.format == AudioStreamWAV.FORMAT_16_BITS else 1)
	elif stream is AudioStreamOggVorbis :
		stream.loop = true
	audio_player.volume_linear = p_volume
	audio_player.play()

func stop(p_sound: String) -> void:
	if !sounds.has(p_sound):
		return
	sounds[p_sound].stop()

func set_pitch(p_sound: String, p_pitch: float) -> void:
	if !sounds.has(p_sound):
		return
	sounds[p_sound].pitch_scale = p_pitch

func set_music(p_music: String, p_volume := 1.0, p_loop := true):
	if p_music == current_song:
		return
	
	if p_music == "":    # Quick change to stop the music.
		var previous_song := music[current_song]
		previous_song.stop()
		current_song = ""    # Clear current_song so playback can restart later.
		return

	if !music.has(p_music):
		printerr("Error in sounds.gd: Attempt to play song, \"" + p_music + "\", but no such song exists.")
		return
	
	if current_song != "":
		var previous_song := music[current_song]
		previous_song.stop()
	var audio_player := music[p_music]
	var stream := audio_player.stream
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if p_loop else AudioStreamWAV.LOOP_DISABLED
	elif stream is AudioStreamOggVorbis:
		stream.loop = p_loop
	audio_player.volume_linear = p_volume
	audio_player.play()
	current_song = p_music
