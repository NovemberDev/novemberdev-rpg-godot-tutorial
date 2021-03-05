extends Node2D

func _ready():
	GLOBALS.current_world = self
	GAMESTATE.connect("on_item_drop", self, "on_item_drop")
	if GAMESTATE.world_state.has(name):
		for node_state in GAMESTATE.world_state[name]:
			match int(node_state.state):
				GAMESTATE.StateType.Removed:
					if $FRONT.has_node(node_state.name):
						$FRONT.get_node(node_state.name).queue_free()
				GAMESTATE.StateType.Added:
					if !$FRONT.has_node(node_state.name):
						var node = load("res://scenes/" + str(node_state.scene)).instance()
						node.position = Vector2(node_state.X, node_state.Y)
						node.rotation = node_state.R
						node.name = node_state.name
						for key in node_state.props.keys():
							node.set(key, node_state.props[key])
						$FRONT.add_child(node)
	
func on_item_drop(item_name, item_quantity):
	var node = load("res://scenes/ITEM.tscn").instance()
	node.item_name = item_name
	node.item_quantity = item_quantity
	node.item_data(GAMESTATE.item_db[item_name])
	node.global_position = GLOBALS.current_player.global_position
	$FRONT.add_child(node)
	GAMESTATE.emit_signal("on_world_state_changed", node, GAMESTATE.StateType.Added, "ITEM.tscn", {
		"item_name": item_name,
		"item_quantity": item_quantity
	})
