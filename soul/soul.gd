extends CharacterBody2D
class_name Soul

@onready var collision: CollisionPolygon2D = $Collision
@onready var grazer: Area2D = $Grazer

@export var battle: Battle
@export var heart: Sprite2D
@export var behaviors: Array[SoulBehavior]

@export_category("Soul Color setting")
enum DebugSoulColor  {
	RED, YELLOW, GREEN, BLUE, PURPLE, ORANGE, CYAN, MONSTER
}
## To test the different soul colors :
@export var debug_start_color : DebugSoulColor = DebugSoulColor.RED
#enum SoulDirection  {
	#"Down : Direction.SOUTH", "Up : Direction.NORTH", "Left : Direction.WEST", "Right : Direction.EAST"
	#Direction.SOUTH, Direction.NORTH, Direction.WEST, Direction.EAST
#}
#@export var soul_direction : Direction = null
#@export_enum("Down : Direction.SOUTH", "Up : Direction.NORTH", "Left : Direction.WEST", "Right : Direction.EAST") var soul_direction = "Down"
## To apply a direction to the YELLOW & BLUE soul colors :

var current_soul_type: SoulType

var active := false:
	set(p_active):
		active = p_active
		grazed_pellets.clear()
var grazed_pellets: Array[Pellet] = []
var invulnerable := false

func _ready() -> void:
	#assign_heart_properties(SoulType.RED)				soul_type_color
	assign_heart_properties(_debug_color_to_soul_type(debug_start_color))
	#visually_rotate(Direction.WEST)
	behaviors[0].face_direction = Direction.WEST
	print(behaviors[0])

func _process(delta: float) -> void:
	for i in behaviors:
		i.tick(delta)

func _physics_process(delta: float) -> void:
	for i in behaviors:
		i.physics_tick(delta)

func _debug_color_to_soul_type(p_color : DebugSoulColor) -> SoulType :
	""" Added myself to change soul color. """
	match p_color :
		DebugSoulColor.RED :
			return SoulType.RED
		DebugSoulColor.CYAN :
			return SoulType.CYAN
		DebugSoulColor.ORANGE :
			return SoulType.ORANGE
		DebugSoulColor.BLUE :
			return SoulType.BLUE
		DebugSoulColor.PURPLE :
			return SoulType.PURPLE
		DebugSoulColor.GREEN :
			return SoulType.GREEN
		DebugSoulColor.YELLOW :
			return SoulType.YELLOW
		DebugSoulColor.MONSTER :
			return SoulType.MONSTER
		_ :
			return SoulType.RED

func hurt(p_damage: int) -> void:
	if invulnerable:
		return
	get_parent().hurt(5 * p_damage)
	invulnerable_state()

func invulnerable_state()-> void:
	invulnerable = true
	var tween = get_tree().create_tween()
	tween.set_loops(5)
	tween.tween_property(heart, "modulate", current_soul_type.get_secondary_color(), 0.0)
	tween.tween_interval(0.1)
	tween.tween_property(heart, "modulate", current_soul_type.color, 0.0)
	tween.tween_interval(0.2)
	await tween.finished
	invulnerable = false

func change_color(soulType : SoulType) -> void:
	current_soul_type = soulType
	heart.modulate = current_soul_type.color
	Global.set_heart_state(current_soul_type)
	visually_rotate(soulType.get_default_direction())

func get_base_color() -> Color:
	return current_soul_type.color

func get_secondary_color() -> Color:
	return current_soul_type.get_secondary_color()

func assign_heart_properties(soulType : SoulType) -> void:
	if soulType == current_soul_type:
		return
	change_color(soulType)
	for i in behaviors:
		i.end()
		i.queue_free()
	behaviors.clear()
	for i in soulType.behaviors:
		var newBehavior := Node.new()
		newBehavior.set_script(i)
		newBehavior.soul = self
		add_child(newBehavior)
		behaviors.append(newBehavior)
		newBehavior.start()

static func heart_rotation(dir : Direction) -> float:
	return dir.positive_degrees - 90

func visually_rotate(dir : Direction) -> void:
	var final_rotation : float = heart_rotation(dir)
	collision.rotation_degrees = final_rotation
	heart.rotation_degrees = final_rotation
	grazer.rotation_degrees = final_rotation
	Global.soulState.set_rotation(dir)
