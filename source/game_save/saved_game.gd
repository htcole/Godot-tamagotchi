# This script extends "Resource" to serve as a custom data container for save slots.
# While SavedData holds the info for a single playthrough/session, SavedGame acts 
# as the top-level container holding all your save slots in one place.
extends Resource

# Registers "SavedGame" as a custom resource class in Godot.
class_name SavedGame

# ==========================================
# SAVE SLOT STORAGE
# ==========================================
# @export makes this visible in the Inspector and ensures Godot includes it when saving to disk.
# Array[SavedData] is a typed array: it strictly holds a list of SavedData resources 
# (e.g., Save Slot 1, Save Slot 2, Save Slot 3).
@export var saved_data: Array[SavedData]
