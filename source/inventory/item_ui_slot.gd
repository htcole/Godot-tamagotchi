# This script extends "Panel", meaning it attaches to a 2D UI box container.
# It acts as the visual controller for a single slot in your inventory interface.
extends Panel

# ==========================================
# UI NODE REFERENCES
# ==========================================
# @onready tells Godot to wait until the UI elements enter the scene tree before finding them.
# Points to the Sprite2D that displays the item's icon image.
@onready var itemDisplay: Sprite2D = $CenterContainer/Panel/ItemDisplay

# Points to the Label node that displays the item stack count (e.g., "5").
@onready var amount_label: Label = $CenterContainer/Panel/AmountLabel

# Stores a reference to the actual Item resource currently displayed in this visual slot.
var item: Item

# ==========================================
# SIGNALS
# ==========================================
# Emitted when the player clicks on this inventory slot UI box.
signal itemPressed()

# ==========================================
# VISUAL DISPLAY UPDATES
# ==========================================
# Refreshes the visual elements (icon and number) based on the data inside an InvSlot.
func update(slot: InvSlot):
	# Case 1: The slot is empty (no item assigned). Hide the icon and number.
	if !slot.item:
		itemDisplay.visible = false
		amount_label.visible = false
	# Case 2: The slot contains an item. Show the icon and stack quantity.
	else:
		itemDisplay.visible = true
		itemDisplay.texture = slot.item.texture # Set icon sprite to the item's texture
		
		# Only display the stack number if the player has 2 or more of the item.
		if slot.amount > 1:
			amount_label.visible = true
		else:
			amount_label.visible = false
			
		amount_label.text = str(slot.amount) # Convert the amount integer into display text
		item = slot.item # Store reference to the item so we know what was clicked

# ==========================================
# INPUT HANDLING
# ==========================================
# Runs automatically whenever an input event (mouse movement, clicks, touches) occurs over the CenterContainer node.
func _on_center_container_gui_input(event):
	# Check if the input event was a Left Mouse Button click.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if the button was pressed down (rather than released).
		if event.pressed:
			# If an item exists in this slot, notify the main UI script that this item was clicked!
			if item:
				print(item.name)
				itemPressed.emit(item)
			pass
