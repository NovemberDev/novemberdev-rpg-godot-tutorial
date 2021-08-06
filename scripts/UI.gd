extends CanvasLayer

var selected_item

func _ready():
	GLOBALS.current_ui = self
	$INVENTORY.visible = false
	GLOBALS.connect("on_toggle_ui", self, "on_toggle_ui")
	GLOBALS.connect("on_refresh_ui", self, "on_refresh_ui")
	$INVENTORY/DESCRIPTION/ITEM.visible = false
	$STATS/INVENTORY.connect("pressed", self, "on_toggle_ui")
	$INVENTORY/CLOSE.connect("pressed", self, "on_toggle_ui")
	$INVENTORY/ScrollContainer/VBoxContainer/TEMPLATE.visible = false
	$INVENTORY/DESCRIPTION/ITEM/BTNDROP.connect("pressed", self, "on_drop_item")
	$INVENTORY/DROP.connect("confirmed", self, "on_drop_confirmed")
	$INVENTORY/DROP/BODY/COUNT.connect("value_changed", self, "on_drop_count_changed")
	$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.connect("item_selected", self, "on_equip")
	$DELETE_SAVE.connect("pressed", self, "on_delete_save")
	on_refresh_ui()
	
func on_toggle_ui():
	$INVENTORY.visible = !$INVENTORY.visible
	
func on_refresh_ui():
	refresh_equip()
	reset_inventory()
	$STATS/HEALTH.value = GAMESTATE.health
	for item_name in GAMESTATE.inventory.keys():
		var item = GAMESTATE.item_db[item_name]
		var quantity = GAMESTATE.inventory[item_name]
		var t = $INVENTORY/ScrollContainer/VBoxContainer/TEMPLATE.duplicate(true)
		t.name = item_name
		t.get_node("TOGGLE").visible = false
		t.get_node("NAME").text = str(item_name)
		t.get_node("PRICE").text = str(item.price) + "G"
		t.get_node("QTY").text = "x " + str(quantity)
		t.get_node("ICON").texture = load("res://assets/textures/" + str(item.icon))
		t.connect("pressed", self, "on_select_item", [t, item_name, item, quantity])
		$INVENTORY/ScrollContainer/VBoxContainer.add_child(t)
		t.visible = true

func on_select_item(node, item_name, item, quantity):
	for n in $INVENTORY/ScrollContainer/VBoxContainer.get_children():
		n.get_node("TOGGLE").visible = false
	selected_item = { 
		item = item,
		quantity = quantity,
		item_name = item_name
	}
	node.get_node("TOGGLE").visible = true
	$INVENTORY/DESCRIPTION/ITEM.visible = true
	$INVENTORY/DESCRIPTION/EMPTY.visible = false
	$INVENTORY/DESCRIPTION/ITEM/NAME.text = str(item_name)
	$INVENTORY/DESCRIPTION/ITEM/PRICE.text = str(item.price) + "G"
	$INVENTORY/DESCRIPTION/ITEM/QTY.text = "x " + str(quantity)
	$INVENTORY/DESCRIPTION/ITEM/ICON.texture = load("res://assets/textures/" + str(item.icon))
	$INVENTORY/DESCRIPTION/ITEM/DESCRIPTION.text = str(item.description)
	if GAMESTATE.left_hand_item_name == item_name:
		$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.select(1)
	elif GAMESTATE.left_hand_item_name == item_name:
		$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.select(2)
	else:
		$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.select(0)
	$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.set_item_disabled(1, item.type != GAMESTATE.ItemType.Equipable)
	$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.set_item_disabled(2, item.type != GAMESTATE.ItemType.Equipable)
	$INVENTORY/DESCRIPTION/ITEM/EQUIPPED.set_item_disabled(3, item.type != GAMESTATE.ItemType.Consumable)

func on_drop_item():
	$INVENTORY/DROP/BODY/COUNT.max_value = int(selected_item.quantity)
	$INVENTORY/DROP/BODY/COUNT.value = int(selected_item.quantity)
	$INVENTORY/DROP/BODY/COUNTTEXT.text = str($INVENTORY/DROP/BODY/COUNT.value) + "/" + str(selected_item.quantity)
	$INVENTORY/DROP.popup()

func on_equip(index):
	match index:
		0:
			if GAMESTATE.right_hand_item_name == selected_item.item_name:
				GAMESTATE.right_hand_item_name = null
			if GAMESTATE.left_hand_item_name == selected_item.item_name:
				GAMESTATE.left_hand_item_name = null
		1:
			GAMESTATE.left_hand_item_name = selected_item.item_name
			if GAMESTATE.right_hand_item_name == selected_item.item_name:
				GAMESTATE.right_hand_item_name = null
		2:
			GAMESTATE.right_hand_item_name = selected_item.item_name
			if GAMESTATE.left_hand_item_name == selected_item.item_name:
				GAMESTATE.left_hand_item_name = null
		3:
			GAMESTATE.emit_signal("on_item_ingest", selected_item.item_name)
	refresh_equip()
	GAMESTATE.emit_signal("on_item_equip")
	
func refresh_equip():
	if GAMESTATE.left_hand_item_name != null:
		$ACTIONS/EQUIPLEFT.icon = load("res://assets/textures/" + GAMESTATE.item_db[GAMESTATE.left_hand_item_name].icon)
	else:
		$ACTIONS/EQUIPLEFT.icon = load("res://assets/textures/ui/ui_buttons1.png")
	if GAMESTATE.right_hand_item_name != null:
		$ACTIONS/EQUIPRIGHT.icon = load("res://assets/textures/" + GAMESTATE.item_db[GAMESTATE.right_hand_item_name].icon)
	else:
		$ACTIONS/EQUIPRIGHT.icon = load("res://assets/textures/ui/ui_buttons2.png")

func on_drop_confirmed():
	GAMESTATE.emit_signal("on_item_drop", selected_item.item_name, $INVENTORY/DROP/BODY/COUNT.value)

func on_drop_count_changed(value):
	$INVENTORY/DROP/BODY/COUNTTEXT.text = str(value) + "/" + str(selected_item.quantity)

func on_interact():
	$INVENTORY.visible = false
	reset_inventory()

func reset_inventory():
	selected_item = null
	$INVENTORY/DESCRIPTION/EMPTY.visible = true
	$INVENTORY/DESCRIPTION/ITEM.visible = false
	for n in $INVENTORY/ScrollContainer/VBoxContainer.get_children():
		if n.name != "TEMPLATE":
			n.name = UUID.NewID()
			n.visible = false
			n.queue_free()
	
func on_delete_save():
	GLOBALS.emit_signal("on_delete_save")
