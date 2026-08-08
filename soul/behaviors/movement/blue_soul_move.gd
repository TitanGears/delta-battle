extends SoulMove

@export var gravity := Vector2(0, 1)
@export var jump_speed_multiplier : float = 1.5 		# 1.2
@export var max_air_time : float = 0.45 				# 0.3

var current_air_time : float = 0

# Added in in order to customize more easily the soul fall direction
## Direction towards which the Soul will fall.
#@export var face_direction : Direction = Direction.SOUTH
@export var jump_input_used := "up"

func start() -> void:
	set_gravity_direction(face_direction)
	if face_direction == Direction.NORTH : jump_input_used = "down"
	elif face_direction == Direction.EAST : jump_input_used = "left"
	elif face_direction == Direction.WEST : jump_input_used = "right"
	soul.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

func tick(delta:float) -> void:
	super.tick(delta)
	if !soul.is_on_floor():
		if current_air_time > 0.0:
			current_air_time -= delta
	else:
		current_air_time = max_air_time

func apply_speed(input : Vector2) -> Vector2:
	var sup := super.apply_speed(input)
	if should_ascend():
		sup += -gravity * speed * jump_speed_multiplier
	elif !soul.is_on_floor():
		sup += gravity * speed
	return sup

# Caused the glitch.
#func get_move_rotation() -> AxisMoveType:
	#return AxisMoveType.ROTATED

func should_ascend() -> bool:
	return Input.is_action_pressed(jump_input_used) && current_air_time > 0.0

func set_gravity_direction(dir : Direction, multiplier : float = 1.0) -> void:
	var dir_to_axis := {
		Direction.NORTH: MoveAxis.X,
		Direction.SOUTH: MoveAxis.X,
		Direction.EAST: MoveAxis.Y,
		Direction.WEST: MoveAxis.Y
	}
	if !dir_to_axis.has(dir):
		return
	set_axis(dir_to_axis.get(dir, MoveAxis.X))
	gravity = Vector2(1, 0).rotated(deg_to_rad(dir.positive_degrees)) * multiplier
	soul.up_direction = -gravity
	soul.visually_rotate(dir)
