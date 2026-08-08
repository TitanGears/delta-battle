extends SoulBehavior

const JUSTICE_PELLET := preload("res://pellets/justice_pellet/justice_pellet.tscn")


#@export var face_direction : Direction = Direction.NORTH
var degrees : float = 0

@export_category("Shooting Properties")
@export var shooting_cooldown : float = 0.2
@export var big_shot_holding_duration : float = 0.7    # 1.0
# Could change by AnimationPlayer if possible? (mostly just to see, is unnecessary)
@export var shooting_enabled : bool = true

@export_category("Charge Sound Properties")
@export var charge_pitch_start : float = 0.6
@export var charge_pitch_end : float = 1.0

var current_cooldown : float = 0
var holdingDuration : float = 0
var is_charging : bool = false

@export var bullets : Array[JusticePellet] = []

func start() -> void:
	set_direction(face_direction)

# Handles shooting
func tick(delta : float) -> void:
	if shooting_disabled():
		if holdingDuration > 0:
			holdingDuration = 0
		stop_charge_sound()
		return
	current_cooldown = maxf(0, current_cooldown-delta)
	if Input.is_action_pressed("confirm"):
		if !shooting_disabled():
			if !is_charging:
				start_charge_sound()
			holdingDuration += delta
			update_charge_pitch()
			if holdingDuration >= big_shot_holding_duration:
				animateBigShottedness(delta)
	else:
		if holdingDuration > 0 && current_cooldown <= 0:
			if !shooting_disabled():
				shoot(holdingDuration>big_shot_holding_duration)
				holdingDuration = 0
				current_cooldown = shooting_cooldown
			soul.heart.modulate = soul.get_base_color()
		stop_charge_sound()

func turn_end() -> void:
	holdingDuration = 0
	soul.heart.modulate = soul.get_base_color()
	stop_charge_sound()
	clear_bullets()

func end() -> void:
	stop_charge_sound()
	clear_bullets()

func clear_bullets() -> void:
	for bullet in bullets.filter(func(bul): return bul != null):
		bullet.queue_free()
	bullets.clear()

func start_charge_sound() -> void:
	is_charging = true
	Sounds.set_pitch("snd_chargeshot_charge", charge_pitch_start)
	Sounds.play_looped("snd_chargeshot_charge", 0.7)

func stop_charge_sound() -> void:
	if !is_charging:
		return
	is_charging = false
	Sounds.stop("snd_chargeshot_charge")

func update_charge_pitch() -> void:
	if is_charging:
		var pitch_amount : float = clampf(holdingDuration / big_shot_holding_duration, 0.0, 1.0)
		Sounds.set_pitch("snd_chargeshot_charge", lerpf(charge_pitch_start, charge_pitch_end, pitch_amount))

func animateBigShottedness(_delta : float) -> void:
	var amount := absf(sin(Time.get_ticks_msec()))
	soul.heart.modulate = soul.get_base_color().lerp(Color.WHITE_SMOKE, amount)

func shoot(is_big_shot : bool = false) -> void:
	var newPellet : JusticePellet = JUSTICE_PELLET.instantiate()
	newPellet.velocity = Vector2(200, 0).rotated(deg_to_rad(degrees + 90))
	newPellet.z_index = soul.z_index-1
	newPellet.is_big_shot = is_big_shot
	newPellet.global_position = soul.global_position + Vector2(8, 0).rotated(deg_to_rad(degrees + 90)) * soul.scale.x
	newPellet.battle = soul.battle
	bullets.append(newPellet)
	soul.get_parent().add_child(newPellet)
	if is_big_shot : Sounds.play("snd_chargeshot_fire", 0.7)
	else : Sounds.play("snd_heartshot_dr_b", 0.7)

func set_direction(dir : Direction) -> void:
	degrees = Soul.heart_rotation(dir)
	face_direction = dir
	# Repetitive bellow, but necessary.
	soul.visually_rotate(dir)
	soul.grazer.rotation_degrees = Soul.heart_rotation(dir)

func shooting_disabled() -> bool:
	return !soul.active || !shooting_enabled
