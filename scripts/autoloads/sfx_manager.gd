extends Node
## SFXManager — global sound effect controller. Provides pooled playback,
## 3D spatialization, pitch randomization, priority-based interruption.
##
## Usage:
##   SFXManager.play(&"player_dash")              # 2D
##   SFXManager.play(&"attack_hit_med", world_pos) # 3D
##
## Add to project autoloads as "SFXManager".

const DEFAULT_POOL_SIZE: int = 4
const DEFAULT_3D_ATTENUATION: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

var _pools: Dictionary = {}  ## sfx_id -> Array[AudioStreamPlayer or AudioStreamPlayer3D]
var _next_pool_index: Dictionary = {}  ## sfx_id -> int (round robin)


func play(sfx_id: StringName, position_3d: Vector3 = Vector3.INF) -> void:
	var sfx: Dictionary = SFXDatabase.get_sfx(sfx_id)
	if sfx.is_empty():
		return
	var stream: AudioStream = _load_sfx_stream(sfx_id)
	if stream == null:
		return  # silently skip — file not yet produced
	var player: Node = _get_pooled_player(sfx_id, sfx)
	if player == null:
		return
	# Apply pitch randomization
	var pitch_min: float = sfx.get("pitch_min", 1.0)
	var pitch_max: float = sfx.get("pitch_max", 1.0)
	var pitch: float = randf_range(pitch_min, pitch_max)
	# Apply volume offset
	var volume_db: float = sfx.get("volume", 0.0)
	if player is AudioStreamPlayer3D:
		var p3d: AudioStreamPlayer3D = player
		p3d.stream = stream
		p3d.pitch_scale = pitch
		p3d.volume_db = volume_db
		if position_3d != Vector3.INF:
			p3d.global_position = position_3d
		p3d.play()
	elif player is AudioStreamPlayer:
		var p2d: AudioStreamPlayer = player
		p2d.stream = stream
		p2d.pitch_scale = pitch
		p2d.volume_db = volume_db
		p2d.play()


func play_random_footstep(surface: StringName, position_3d: Vector3 = Vector3.INF) -> void:
	var random_id: StringName = SFXDatabase.get_random_footstep(surface)
	if random_id != &"":
		play(random_id, position_3d)


# === POOLING ===

func _get_pooled_player(sfx_id: StringName, sfx_data: Dictionary) -> Node:
	if not _pools.has(sfx_id):
		_create_pool(sfx_id, sfx_data)

	var pool: Array = _pools[sfx_id]
	if pool.is_empty():
		return null

	var pool_size: int = pool.size()
	var start_idx: int = _next_pool_index.get(sfx_id, 0)

	# Find a free player (not currently playing)
	for i in pool_size:
		var idx: int = (start_idx + i) % pool_size
		var p: Node = pool[idx]
		var is_playing: bool = false
		if p is AudioStreamPlayer3D:
			is_playing = (p as AudioStreamPlayer3D).playing
		elif p is AudioStreamPlayer:
			is_playing = (p as AudioStreamPlayer).playing
		if not is_playing:
			_next_pool_index[sfx_id] = (idx + 1) % pool_size
			return p

	# All busy — recycle the oldest (round robin)
	var idx: int = start_idx
	_next_pool_index[sfx_id] = (idx + 1) % pool_size
	return pool[idx]


func _create_pool(sfx_id: StringName, sfx_data: Dictionary) -> void:
	var pool_size: int = sfx_data.get("pool", DEFAULT_POOL_SIZE)
	var spatial: bool = sfx_data.get("spatial", false)
	var category: StringName = sfx_data.get("category", &"sfx_world")
	var bus_name: StringName = _category_to_bus(category)

	var pool: Array = []
	for i in pool_size:
		var p: Node
		if spatial:
			var p3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			p3d.attenuation_model = DEFAULT_3D_ATTENUATION
			p3d.unit_size = 5.0
			p3d.max_distance = 30.0
			p3d.bus = bus_name
			p = p3d
		else:
			var p2d: AudioStreamPlayer = AudioStreamPlayer.new()
			p2d.bus = bus_name
			p = p2d
		add_child(p)
		pool.append(p)
	_pools[sfx_id] = pool
	_next_pool_index[sfx_id] = 0


func _category_to_bus(category: StringName) -> StringName:
	match category:
		&"world":  return &"SFX_World"
		&"combat": return &"SFX_Combat"
		&"ui":     return &"SFX_UI"
	return &"Master"


func _load_sfx_stream(sfx_id: StringName) -> AudioStream:
	var path: String = SFXDatabase.get_file_path(sfx_id)
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


# === HOTLOAD AHEAD-OF-TIME ===

func preload_category(category: StringName) -> int:
	## Pre-creates pools for all SFX in a category. Use during scene load
	## to avoid first-play hitches. Returns count loaded.
	var count: int = 0
	for s in SFXDatabase.get_all():
		if s["category"] == category:
			var sfx_id: StringName = s["id"]
			if not _pools.has(sfx_id):
				_create_pool(sfx_id, s)
				count += 1
	return count


# === STOP / CLEANUP ===

func stop_all_in_category(category: StringName) -> void:
	for sfx_id: StringName in _pools.keys():
		var sfx: Dictionary = SFXDatabase.get_sfx(sfx_id)
		if sfx.get("category", &"") != category:
			continue
		for p in _pools[sfx_id]:
			if p is AudioStreamPlayer3D and (p as AudioStreamPlayer3D).playing:
				(p as AudioStreamPlayer3D).stop()
			elif p is AudioStreamPlayer and (p as AudioStreamPlayer).playing:
				(p as AudioStreamPlayer).stop()


func clear_all_pools() -> void:
	for sfx_id: StringName in _pools.keys():
		for p in _pools[sfx_id]:
			if is_instance_valid(p):
				p.queue_free()
	_pools.clear()
	_next_pool_index.clear()
