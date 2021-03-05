extends INTERACTABLE

var item
export(String) var item_name
export(int) var item_quantity

func _ready():
	if item_name != null:
		item_data(GAMESTATE.item_db[item_name])
		
func item_data(data):
	item = data
	$MODEL/Sprite.texture = load("res://assets/textures/" + str(item.icon))
	
func _interact(actor):
	can_interact = false
	$MODEL/AnimationPlayer.play("despawn")
	GAMESTATE.emit_signal("on_item_pickup", self)
	GAMESTATE.emit_signal("on_world_state_changed", self)
	return true




