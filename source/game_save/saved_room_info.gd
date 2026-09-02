# Extends "SavedData" to inherit base save resource functionality.
# This script specifically holds save data related to room progression, available rooms, and the pets inside them.
extends SavedData

# Registers "SavedRoomInfo" as a custom resource class in Godot.
class_name SavedRoomInfo

# ==========================================
# SAVED ROOM & PET DATA
# ==========================================
# @export ensures these values are saved to disk when the game saves.

# Tracks which room the player is currently viewing or residing in (e.g., Room 0, Room 1).
@export var current_room_index: int

# Total number of unlocked or existing rooms in the game.
@export var total_rooms: int

# Stores an array of manager data for pets in rooms (such as SavedPetManager instances or exit timer dictionaries).
@export var pets_manager_info: Array

# Stores an array of pet save snapshots (instances of SavedPet) for all pets residing across rooms.
@export var pets_info: Array
