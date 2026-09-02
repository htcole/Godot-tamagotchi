# Extends "Control", making this the main user interface popup panel for displaying 
# and interacting with the player's inventory items (such as feeding food items to pets).
extends Control

# ==========================================
# SIGNALS
# ==========================================
# Emitted when the player selects a consumable food item to feed to their active pet.
signal foodSelected(food_item)

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Grabs reference to the main action HUD to listen for inventory opening/closing signals.
@onready var buttons_ui = get_tree().get_first_node_in_group("ButtonsUI")

# Reference to the player's runtime inventory resource container.
@onready var inv: Inventory = preload("res://source/inventory/player_inv.tres")

# Stores references to existing UI slot instances inside the grid layout container.
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

# Holds a reference to the currently clicked/selected Item resource.
@onready var selected_item: Item

# Preloads the slot UI scene template instantiated dynamically for new inventory items.
@onready var itemSlotScene = preload("res://source/inventory/item_ui_slot.tscn")

# Grid container parent node where item UI slot instances are attached as children.
@onready var itemUIContainer = $NinePatchRect/GridContainer

# Retrieves reference to the active Pet node in the scene tree.
@onready var pet = get_tree().get_first_node_in_group("Pet")

# ==========================================
# CONSTANTS & PATHS
# ==========================================
# Path prefix and naming convention used to locate and construct dynamic slot nodes.
var ITEM_UI_CONTAINER_PATH = "NinePatchRect/GridContainer/"
var ITEM_UI_SLOT_NAME = 'ItemUISlot'
var shop_active = false

# ==========================================
# INITIALIZATION & SIGNAL SETUP
# ==========================================
func _ready():
	setup_signals()
	# Hide inventory panel on boot until requested by the player.
	self.visible = false

# Listens for HUD UI events, pet consumption events, and inventory removal signals.
func setup_signals():
	buttons_ui.openInventory.connect(open_inventory)
	buttons_ui.closeUI.connect(close_inventory)
	pet.pet_actions.itemConsumed.connect(_on_item_consumed)
	inv.itemRemoved.connect(remove_item_ui_slot)

# Ensures local `inv` reference matches `Global.inv` after loading save data.
func update_loaded_in_inv():
	inv = Global.inv
	inv.itemRemoved.connect(remove_item_ui_slot)

# ==========================================
# INVENTORY MANAGEMENT & FILTERING
# ==========================================
# Filters inventory slots by item type (e.g. Food), creates missing UI slots, and refreshes icons.
func update_inventory(item_type):
	if Global.inv != inv:
		update_loaded_in_inv()
	var item_type_slots = get_item_type_slots(item_type)
	check_for_new_slots(item_type_slots)
	update_slots(item_type_slots)

# Returns a filtered array containing only slots matching the specified ItemType (e.g., Food).
func get_item_type_slots(item_type: Item.ItemType) -> Array[InvSlot]:
	var filtered_slots: Array[InvSlot] = []
	for slot in inv.slots:
		if slot.item and slot.item.type == item_type:
			filtered_slots.append(slot)
	return filtered_slots

# ==========================================
# DYNAMIC UI SLOT MANAGEMENT
# ==========================================
# Spawns new UI slot scenes for items in inventory that don't have a visual UI node yet.
func check_for_new_slots(item_type_slots):
	for slot in item_type_slots:
		if !get_item_ui_node(slot.item.name):
			create_item_ui_slot(slot)

# Helper function to find an existing item slot UI node by item name.
func get_item_ui_node(item_name: String):
	var node_name = ITEM_UI_SLOT_NAME + item_name
	var node_path = ITEM_UI_CONTAINER_PATH + node_name
	if has_node(node_path):
		return get_node(node_path)
	else:
		return null

# Instantiates a new ItemUISlot scene, assigns a unique node name, connects click signals, and appends to UI.
func create_item_ui_slot(slot: InvSlot):
	var item_ui_slot = itemSlotScene.instantiate()
	item_ui_slot.name = ITEM_UI_SLOT_NAME + slot.item.name
	itemUIContainer.add_child(item_ui_slot)
	item_ui_slot.itemPressed.connect(item_selected)
	slots.append(item_ui_slot)

# Disconnects signals and destroys a slot UI node when its item count reaches zero or is removed.
func remove_item_ui_slot(item: Item):
	var item_slot_ui = get_item_ui_node(item.name)
	if item_slot_ui:
		item_slot_ui.itemPressed.disconnect(item_selected)
		slots.erase(item_slot_ui)
		item_slot_ui.queue_free()

# Updates visible UI slot elements with updated item counts and graphics.
func update_slots(item_type_slots: Array[InvSlot]):
	for i in range(min(item_type_slots.size(), slots.size())):
		slots[i].update(item_type_slots[i])

# ==========================================
# ITEM SELECTION & CONSUMPTION
# ==========================================
# Called when the player clicks on a specific item slot in the panel.
func item_selected(item: Item):
	selected_item = item
	# If the selected item is food, emit foodSelected so pet action handlers can feed the pet!
	if selected_item.type == Item.ItemType.Food:
		foodSelected.emit(selected_item)
	close_inventory()

# Called when the pet finishes eating an item: removes item from inventory resource and refreshes UI.
func _on_item_consumed(item: Item):
	inv.remove_item(item)
	update_slots(get_item_type_slots(Item.ItemType.Food))

# ==========================================
# DISPLAY & VISIBILITY CONTROLS
# ==========================================
# Toggles inventory window visibility and populates items filtered by category.
func open_inventory(item_type):
	# Toggle off if already open when clicked again.
	if self.visible == true:
		close_inventory()
		return
	update_inventory(item_type)
	self.visible = true

# Close button handler.
func _on_close_button_pressed():
	close_inventory()

# Hides the inventory panel.
func close_inventory():
	self.visible = false
