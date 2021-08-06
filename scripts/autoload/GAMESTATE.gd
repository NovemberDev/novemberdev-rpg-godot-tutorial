extends Node

var health = 50
var inventory = {}
var world_state = {}
var left_hand_item_name
var right_hand_item_name
signal on_item_drop
signal on_item_equip
signal on_item_pickup
signal on_item_ingest
signal on_world_state_changed

func _ready():
	GLOBALS.connect("on_delete_save", self, "on_delete_save")
	connect("on_world_state_changed", self, "on_world_state_changed")
	connect("on_item_ingest", self, "on_item_ingest")
	connect("on_item_pickup", self, "on_item_pickup")
	connect("on_item_drop", self, "on_item_drop")
	var f = File.new()
	if f.open("user://save.json", File.READ) == 0:
		var state = JSON.parse(f.get_as_text()).result
		health = try_get_value(state, "health", health)
		inventory = try_get_value(state, "inventory", inventory)
		world_state = try_get_value(state, "world_state", world_state)
		left_hand_item_name = try_get_value(state, "left_hand_item_name", left_hand_item_name)
		right_hand_item_name = try_get_value(state, "right_hand_item_name", right_hand_item_name)
		f.close()
		
func _exit_tree():
	var f = File.new()
	if f.open("user://save.json", File.WRITE) == 0:
		f.store_string(JSON.print({
			health = health,
			inventory = inventory,
			world_state = world_state,
			left_hand_item_name = left_hand_item_name,
			right_hand_item_name = right_hand_item_name
		}))
		f.close()
	
func on_item_ingest(item_name):
	health = clamp(health + item_db[item_name].health, 0, 100)
	inventory[item_name] -= 1
	if inventory[item_name] < 1:
		inventory.erase(item_name)
	GLOBALS.emit_signal("on_refresh_ui")
	
func on_item_pickup(item):
	if inventory.has(item.item_name):
		inventory[item.item_name] += item.item_quantity
	else:
		inventory[item.item_name] = item.item_quantity
	GLOBALS.emit_signal("on_refresh_ui")
	
func on_item_drop(item_name, item_quantity):
	if inventory.has(item_name):
		if inventory[item_name] <= item_quantity:
			inventory.erase(item_name)
			if left_hand_item_name == item_name:
				left_hand_item_name = null
			if right_hand_item_name == item_name:
				right_hand_item_name = null
		else:
			inventory[item_name] -= item_quantity
	GLOBALS.current_player.some_method()
	GLOBALS.current_ui.some_method()
	GLOBALS.emit_signal("on_refresh_ui")

func on_world_state_changed(node, state_type = StateType.Removed, scene = null, properties = []):
	if !world_state.has(GLOBALS.current_world.name):
		world_state[GLOBALS.current_world.name] = []
	world_state[GLOBALS.current_world.name].push_back({ 
		scene = scene,
		X = node.global_position.x,
		Y = node.global_position.y,
		R = node.rotation,
		name = node.name,
		state = state_type,
		props = properties 
	})

func try_get_value(source, key, val):
	if source.has(key):
		return source[key]
	return val

func on_delete_save():
	health = 50
	inventory = {}
	world_state = {}
	left_hand_item_name = null
	right_hand_item_name = null
	var dir = Directory.new()
	dir.remove("user://save.json")
	get_tree().reload_current_scene()

enum StateType {
	Removed = 0,
	Added = 1
}

enum ItemType {
	Consumable,
	Equipable
}

var item_db = {
	"Knife": {
		type = ItemType.Equipable,
		icon = "items_knife.png",
		sprite = "item_knife.png",
		description = "Stab to deal 25 damage",
		damage = 25,
		price = 10
	},
	"Eyefruit": {
		type = ItemType.Consumable,
		icon = "items_eyefruit.png",
		description = "Delicious eye fruit",
		health = 50,
		price = 5
	}
}

