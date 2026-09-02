# Extends "Resource" so your player's entire inventory state can be saved, loaded, 
# and shared across different UI nodes easily as a single data object.
extends Resource

# Registers "Inventory" as a custom resource class in Godot.
class_name Inventory

# ==========================================
# SIGNALS
# ==========================================
# Emitted whenever the inventory contents change (items added or removed) so UI grid nodes know to refresh.
signal update

# Emitted specifically when an item's stack count reaches 0 and it gets removed completely.
signal itemRemoved(item)

# ==========================================
# INVENTORY SLOTS
# ==========================================
# Typed array that strictly holds InvSlot resources (each representing one slot/stack in the inventory).
@export var slots: Array[InvSlot]

# ==========================================
# ITEM MANAGEMENT FUNCTIONS
# ==========================================
# Adds an item into the inventory, stacking it if it already exists or creating a new slot if it doesn't.
func insert(item: Item):
	# `.filter()` searches through the slots array and returns only slots where slot.item matches the added item.
	var item_slots = slots.filter(func(slot): return slot.item == item)
	
	# If an existing stack for this item was found, just increase its quantity by 1.
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	else:
		# Otherwise, create a brand-new slot and put the item in it with a starting amount of 1.
		add_slot()
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
			
	# Notify connected UI nodes to refresh display icons and counts.
	update.emit()

# Decrements an item count by 1 (for example, when feeding the pet or selling an item).
func remove_item(item: Item):
	# Find any slot holding this specific item type.
	var item_slots = slots.filter(func(slot): return slot.item == item)
	
	if !item_slots.is_empty():
		item_slots[0].amount -= 1
		
		# If the quantity hits 0, erase the slot completely from the inventory.
		if item_slots[0].amount <= 0:
			slots.erase(item_slots[0])
			itemRemoved.emit(item)
			
		# Refresh UI and exit function early.
		update.emit()
		return
		
	# `assert(false, ...)` is a safety check: if the game tries to remove an item that isn't in inventory, 
	# Godot will pause execution in debug mode and display an error message.
	assert(false, "Item not found in inventory: %s" % item.name)

# Helper function to append a new InvSlot instance onto the slots array.
func add_slot():
	var new_slot = InvSlot.new()
	slots.append(new_slot)
