# Extends "Control", making this the main UI toolbar panel where the player clicks buttons
# to perform care actions (feed, pet, clean) or open game sub-menus (shop, computer, inventory).
extends Control

# ==========================================
# STATE & REFERENCES
# ==========================================
# Holds a reference to the pet node currently in the active room.
@onready var pet: Node = null

# ==========================================
# SIGNALS
# ==========================================
# Emitted when an interaction button is clicked (e.g., "feed", "clean", "love").
signal selectedAction(action)

# Emitted to open the shop menu interface.
signal selectedShop()

# Emitted to open the player inventory (optionally filtering by ItemType).
signal openInventory()

# Emitted to open the computer/sanctuary management screen.
signal openComputer()

# Emitted to signal other UI overlays/windows to close when opening a full screen overlay.
signal closeUI()

# ==========================================
# INITIALIZATION & PET BINDING
# ==========================================
func _ready():
	# Finds the RoomManager node and listens for room/pet switching.
	var room_manager = get_parent().get_node("RoomManager")
	room_manager.ActivePetChanged.connect(update_pet)

# Rebinds action signals whenever the player switches rooms or active pets.
func update_pet(new_pet: Node):
	# If bound to a previous pet, disconnect the signal to prevent sending commands to the wrong pet.
	if pet:
		disconnect("selectedAction", Callable(pet.pet_actions, "pet_action"))
		
	pet = new_pet
	
	# Connect the "selectedAction" signal directly to the new pet's "pet_action" handler function in PetActions.gd!
	connect("selectedAction", Callable(pet.pet_actions, "pet_action"))

# ==========================================
# UI BUTTON CALLBACKS
# ==========================================
# Triggered when the "Feed" button is pressed.
func _on_feed_button_pressed():
	# Open inventory showing food items and notify pet system.
	emit_signal("openInventory", Item.ItemType.Food)
	emit_signal("selectedAction", "feed")

# Triggered when the "Clean" button is pressed.
func _on_clean_button_pressed():
	emit_signal("selectedAction", "clean")

# Triggered when the "Love" button is pressed.
func _on_love_button_pressed():
	emit_signal("selectedAction", "love")

# Triggered when the "Fun" button is pressed.
func _on_fun_button_pressed():
	emit_signal("selectedAction", "fun")

# Triggered when the "Social" button is pressed.
func _on_social_button_pressed():
	emit_signal("selectedAction", "social")

# Triggered when the "Sleep" button is pressed.
func _on_sleep_button_pressed():
	emit_signal("selectedAction", "sleep")

# Triggered when the "Shop" button is pressed.
func _on_shop_button_pressed():
	emit_signal("selectedShop")

# Triggered when the "Computer" button is pressed.
func _on_computer_button_pressed():
	emit_signal("closeUI")
	emit_signal("openComputer")
