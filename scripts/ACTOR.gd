extends KinematicBody2D
class_name ACTOR

export(float) var DAMAGE = 25.0
export(float) var FRICTION = 20.0
export(float) var KNOCKBACK_MODIFIER = 5.0
export(float) var KNOCKBACK_STRENGTH = 100.0
export(Vector2) var WALK_SPEED = Vector2(50.0, -50.0)

export(float) var health = 100.0

var is_dead = false
var linear_velocity = Vector2.ZERO
var current_knockback = Vector2.ZERO
var current_orientation = Vector2.ZERO

var footstep_scene = load("res://scenes/FOOTSTEP.tscn")

func _process(delta):
	current_knockback = lerp(current_knockback, Vector2.ZERO, delta * KNOCKBACK_MODIFIER)

func knockback(source_position):
	current_knockback = (global_position - source_position).normalized() * KNOCKBACK_STRENGTH

func footstep(name, is_left):
	var f = footstep_scene.instance()
	GLOBALS.current_world.get_node("FX").add_child(f)
	if name == "side":
		f.global_position = $MODEL/FX_FOOT_SIDE.global_position
		f.scale = $MODEL/FX_FOOT_SIDE.scale
	else:
		if is_left:
			f.global_position = $MODEL/FX_FOOT_LEFT.global_position
			f.scale = $MODEL/FX_FOOT_LEFT.scale
		else:
			f.global_position = $MODEL/FX_FOOT_RIGHT.global_position
			f.scale = $MODEL/FX_FOOT_RIGHT.scale
	f.play(name)

func take_damage(actor):
	knockback(actor.global_position)
	_take_damage(actor)

# virtual method which can be overwritten
# by any class which inherits ACTOR
func _take_damage(actor):
	pass
