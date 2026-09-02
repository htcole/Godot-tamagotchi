# Extends "Control", making this the primary user interface controller for the food store screen.
# It manages displaying items available for sale, handling item selection, and processing purchases using Global coins.
extends Control

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Preloads the Inventory resource that defines which items are available for purchase in this store.
@onready var inv: Inventory = preload("res://source/inventory/food_store_inv.tres")

# Stores an array of all child UI slot nodes inside the GridContainer container.
@onready var slots: Array = $GridContainer.get_children()

# Holds a reference to the item resource currently selected by the player in the shop menu.
@onready var selected_item: Item

# UI node references for displaying details about the selected item.
@onready var selected_item_sprite = $SelectedItemSprite
@onready var selected_item_label = $SelectedItemLabel
@onready var item_price_label = $ItemPrice
@onready var anim_player = $AnimationPlayer

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Preload a default fallback item (Banana) to ensure a selection exists on boot.
	selected_item = preload("res://source/inventory/items/foods/banana.tres")
	
	# Connect to inventory updates so slot graphics refresh automatically if store stock changes.
	inv.update.connect(update_slots)
	
	# Connect button signals for every slot in the grid container.
	connect_slots_signals()
	
	# Initial visual update of store slots.
	update_slots()

# ==========================================
# SLOT BINDING & REFRESH LOGIC
# ==========================================
# Loops through all slot UI elements and connects their "itemPressed" signal to item_selected().
func connect_slots_signals():
	for slot in slots:
		slot.itemPressed.connect(item_selected)

# Updates each visual UI slot in the grid with data from the store's Inventory resource.
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

# ==========================================
# SELECTION & PURCHASE LOGIC
# ==========================================
# Called when the player clicks on a shop item slot. Updates the display panel details.
func item_selected(item):
	selected_item = item
	selected_item_sprite.texture = item.texture
	selected_item_label.text = item.name
	item_price_label.text = 'Price:' + str(item.price)

# Called when the "Buy" button is pressed.
func _on_button_pressed():
	if selected_item:
		# Check if the player has enough global coins to afford the selected item.
		if selected_item.price > Global.coins:
			print('Cannot afford this.')
			return
			
		# Deduct item price from global balance (triggers Global.coins setter and updates UI).
		Global.coins -= selected_item.price
		
		# Add the purchased item directly into the player's main inventory!
		Global.collect(selected_item)
