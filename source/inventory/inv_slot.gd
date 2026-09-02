# Extends "Resource" so that each individual slot in your inventory can be saved,
# loaded, and managed as its own lightweight data object.
extends Resource

# Registers "InvSlot" as a custom resource class in Godot.
class_name InvSlot

# ==========================================
# INVENTORY SLOT DATA
# ==========================================
# @export ensures these fields can be saved to disk and edited in the Inspector.

# Holds the reference to the specific Item resource residing in this slot (e.g., Apple, Toy).
@export var item: Item

# Tracks how many of this item are currently stacked in this slot (e.g., 5 Apples).
@export var amount: int
