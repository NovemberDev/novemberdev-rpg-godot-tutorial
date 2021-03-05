extends ACTOR

var movement_timeout = 1.5
var movement = Vector2.ZERO

func _ready():
	if !is_in_group("mob"):
		add_to_group("mob")

func _process(delta):
	movement_timeout -= delta
	if movement_timeout <= 0.0:
		movement = 2.0 * Vector2(randf() - 0.5, randf() - 0.5) * WALK_SPEED
		movement_timeout = 1.5
	
	movement = lerp(movement, Vector2.ZERO, 0.75 * delta)
	move_and_slide(movement + current_knockback)

func _take_damage(actor):
	if is_dead: return
	health -= actor.DAMAGE
	$MODEL/AnimationPlayer.play("damage")
	$MODEL/FX/AnimationPlayer.play("hit")
	if health <= 0.0:
		$MODEL/AnimationPlayer.play("death")
		is_dead = true
		GAMESTATE.emit_signal("on_world_state_changed", self)
