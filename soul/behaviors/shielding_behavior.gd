extends SoulBehavior

const SHIELD = preload("res://soul/behaviors/behavior_assets/shielding/shield.tscn")

@export var shield_scale : float = 1.0

var shield : Shield
var currentDirection : Direction = Direction.NORTH
var currentRotation : float = -90

var turning : bool = false

func start() -> void:
	create_shield()
	rotate_shield(currentRotation)

#func _unhandled_input(_event: InputEvent) -> void:
	# Switched to _process() in order to stay diagonally when releasing both keys at once.
func _process(_delta : float) -> void:
	if !soul.active || turning:
		return
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
	if direction == Vector2.ZERO:
		return
	
	#var newDirection : Direction = Direction.from_vector(direction)
	#if newDirection == currentDirection.left():
		#rotate_shield(90)
	#elif newDirection == currentDirection.right():
		#rotate_shield(-90)
	#elif newDirection == currentDirection.opposite():
		#rotate_shield(180)
	#currentDirection = newDirection
	
	#if direction == Vector2.UP:
		#if currentDirection == Direction.EAST:
			#rotate_shield(-90)
		#elif currentDirection == Direction.WEST:
			#rotate_shield(90)
		#elif currentDirection == Direction.SOUTH:
			#rotate_shield(180)
		#currentDirection = Direction.NORTH
	#elif direction == Vector2.DOWN:
		#if currentDirection == Direction.EAST:
			#rotate_shield(90)
		#elif currentDirection == Direction.WEST:
			#rotate_shield(-90)
		#elif currentDirection == Direction.NORTH:
			#rotate_shield(180)
		#currentDirection = Direction.SOUTH
	#elif direction == Vector2.RIGHT:
		#if currentDirection == Direction.NORTH:
			#rotate_shield(90)
		#elif currentDirection == Direction.SOUTH:
			#rotate_shield(-90)
		#elif currentDirection == Direction.WEST:
			#rotate_shield(180)
		#currentDirection = Direction.EAST
	#elif direction == Vector2.LEFT:
		#if currentDirection == Direction.EAST:
			#rotate_shield(180)
		#elif currentDirection == Direction.NORTH:
			#rotate_shield(-90)
		#elif currentDirection == Direction.SOUTH:
			#rotate_shield(90)
		#currentDirection = Direction.WEST
	# New added parameters for diagonals :
	# DELETED FOR BEING WAY TOO LONG (and requiring other stuff)
	
	# New bellow to have diagonals (might have to test with a controller)
	var direction_int : Vector2i = Vector2i(int(sign(direction.x)), int(sign(direction.y)))
	var newDirection : Direction = Direction.from_vector(direction_int)
	#if newDirection == null :
		#return					#  seems unecessary in retrospect
	if newDirection == currentDirection:
		return
	
	var angle_delta : float = shield_angle_difference(currentDirection.positive_degrees, newDirection.positive_degrees)
	rotate_shield(angle_delta)
	currentDirection = newDirection

func shield_angle_difference(from_angle : float, to_angle : float) -> float :
	var delta : float = fmod(to_angle - from_angle, 360.0)
	if delta > 180.0 :
		delta -= 360.0
	elif delta < -180.0 :
		delta += 360.0
	return delta


func end() -> void:
	shield.queue_free()

func turn_start() -> void:
	shield.visible = true

func turn_end() -> void:
	shield.visible = false

func rotate_shield(degrees : float) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	turning = true	
	#tween.tween_property(shield, "rotation_degrees", shield.rotation_degrees + degrees, 0.05)			# OLD code for 4 directions here
	#tween.tween_callback(func(): turning = false)
	#shield.rotation_degrees = int(shield.rotation_degrees) % 360
	var target_rotation : float = shield.rotation_degrees + degrees
	tween.tween_property(shield, "rotation_degrees", target_rotation, 0.05)
	tween.tween_callback(func() :
		turning = false
		shield.rotation_degrees = fposmod(shield.rotation_degrees, 360.0)
	)

func create_shield() -> void:
	var newShield : Shield = SHIELD.instantiate()
	newShield.scale *= shield_scale
	newShield.show_behind_parent = true
	soul.add_child(newShield)
	shield = newShield
