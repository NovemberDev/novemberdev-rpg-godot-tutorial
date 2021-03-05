extends StaticBody2D
class_name INTERACTABLE

var can_interact = true

func _ready():
	if !is_in_group("interactable"):
		add_to_group("interactable")
	$MODEL/Sprite.material.set_shader_param("width", 0.0)

func toggle_select(toggle):
	if toggle and can_interact:
		$MODEL/AnimationPlayer.play("select")
	else:
		$MODEL/AnimationPlayer.stop()
		$MODEL/Sprite.material.set_shader_param("width", 0.0)

func _interact(actor):
	pass


