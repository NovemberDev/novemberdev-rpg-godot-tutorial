extends ACTOR

var can_move = true
var direction_input = Vector2.ZERO

func _ready():
	if !is_in_group("player"):
		add_to_group("player")
	on_item_equip()
	$Camera2D.current = true
	GLOBALS.current_player = self
	$MODEL/AnimationTree.active = true
	GAMESTATE.connect("on_item_equip", self, "on_item_equip")
	GAMESTATE.connect("on_item_ingest", self, "on_item_ingest")
	$InteractSensor.connect("body_exited", self, "on_interact_body_exited")
	$InteractSensor.connect("body_entered", self, "on_interact_body_entered")
	
func _process(delta):
	direction_input = Vector2.ZERO
	direction_input.x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	direction_input.y = int(Input.is_key_pressed(KEY_W)) - int(Input.is_key_pressed(KEY_S))
	
	if direction_input != Vector2.ZERO:
		linear_velocity = lerp(linear_velocity, direction_input * WALK_SPEED, delta * 5.0)
		$MODEL/AnimationTree.set("parameters/state/current", 1)
		current_orientation = direction_input
	else:
		linear_velocity = lerp(linear_velocity, Vector2.ZERO, delta * FRICTION)
		$MODEL/AnimationTree.set("parameters/state/current", 0)
	
	move_and_slide(linear_velocity + current_knockback)
	$MODEL/AnimationTree.set("parameters/move/blend_position", current_orientation)
	$MODEL/AnimationTree.set("parameters/idle/blend_position", current_orientation)
	
	if Input.is_action_just_pressed("attack") and is_weapon_equipped():
		$MODEL/AnimationTree.set("parameters/attack/active", true)
	if Input.is_action_just_pressed("interact"):
		for body in $InteractSensor.get_overlapping_bodies():
			if body.is_in_group("interactable"):
				if body._interact(self):
					$MODEL/FX/AnimationPlayer.play("action")
	if Input.is_action_just_pressed("inventory"):
		GLOBALS.emit_signal("on_toggle_ui")

func on_interact_body_entered(body):
	if body.is_in_group("interactable"):
		body.toggle_select(true)
func on_interact_body_exited(body):
	if body.is_in_group("interactable"):
		body.toggle_select(false)

func on_item_equip():
	if GAMESTATE.left_hand_item_name == "Knife":
		if !$MODEL/LEFTHAND.visible:
			var d = current_orientation * Vector2(2.0, 1.0) - Vector2(float($MODEL/LEFTHAND.visible), 0)
			$MODEL/AnimationTree.set("parameters/attack_bs/blend_position", d)
			$MODEL/FX/AnimationPlayer.play("action")
			$MODEL/LEFTHAND.visible = true
	else:
		$MODEL/LEFTHAND.visible = false
	if GAMESTATE.right_hand_item_name == "Knife":
		if !$MODEL/RIGHTHAND.visible:
			var d = current_orientation * Vector2(2.0, 1.0) + Vector2(float($MODEL/RIGHTHAND.visible), 0)
			$MODEL/AnimationTree.set("parameters/attack_bs/blend_position", d)
			$MODEL/FX/AnimationPlayer.play("action")
			$MODEL/RIGHTHAND.visible = true
	else:
		$MODEL/RIGHTHAND.visible = false

func is_weapon_equipped():
	return $MODEL/LEFTHAND.visible or $MODEL/RIGHTHAND.visible

func stop_control():
	can_move = false

func apply_damage():
	can_move = true
	for body in $InteractSensor.get_overlapping_bodies():
		if body.is_in_group("mob"):
			body.take_damage(self)

func on_item_ingest(i):
	$MODEL/FX/AnimationPlayer.play("action")
