# Extends "Control", making this the room store screen on the computer panel.
# Handles displaying purchase prices for additional sanctuary rooms, validating coin balance,
# and signaling RoomManager to instantiate new rooms when bought.
extends Control

# ==========================================
# NODE REFERENCES
# ==========================================
# Optional AnimationPlayer for room store page visual transitions.
@onready var anim_player = $AnimationPlayer

# Container UI node wrapping the buy button and price display elements.
@onready var shop_container = $VBoxContainer

# Label used to show messages ("Max rooms reached" or "Thank you for purchase").
@onready var screen_text_label = $MaxRoomsLabel

# Text label displaying the current room purchase cost.
@onready var price_label = $VBoxContainer/HBoxContainer/PriceLabel

# Direct reference to the core RoomManager node handling room generation.
@onready var roomManager = get_tree().get_root().get_node("MainScene/RoomManager")

# ==========================================
# ECONOMY & SETTERS
# ==========================================
# Uses GDScript's custom setter (`set(new_value)`) to automatically update 
# the price label text on screen whenever `room_price` is updated in code.
var room_price: int = 10:
	set(new_value):
		price_label.text = str(new_value)

# ==========================================
# INITIALIZATION & DISPLAY UPDATE
# ==========================================
func _ready():
	pass

# Called when opening the room expansion store page to update price and availability based on total owned rooms.
func update():
	var rooms_number = roomManager.rooms.size()
	shop_container.visible = true
	screen_text_label.visible = false
	
	# Adjust price based on how many rooms the player currently owns.
	if rooms_number == 1:
		# First expansion room costs default base price (10 coins).
		pass
	if rooms_number == 2:
		# Second expansion room increases price to 25 coins.
		room_price = 25
	if rooms_number >= 3:
		# Hide purchase interface if player reached the maximum room limit.
		shop_container.visible = false
		screen_text_label.text = 'You already have max amount of rooms.'
		screen_text_label.visible = true

# ==========================================
# PURCHASE BUTTON HANDLER
# ==========================================
# Triggered when clicking the "Purchase Room" button.
func _on_button_pressed():
	# Verify player has enough coins balance in Global.
	if room_price > Global.coins:
		print('Cannot afford this.')
		return
		
	# Deduct funds (setter emits coinsChanged to update coin HUD counter).
	Global.coins -= room_price
	
	# Signal RoomManager to unlock and generate the new room!
	roomManager.room_purchased()
	
	# Hide purchase container and confirm purchase on screen.
	shop_container.visible = false
	screen_text_label.text = 'Thank you for your purchase!'
	screen_text_label.visible = true
