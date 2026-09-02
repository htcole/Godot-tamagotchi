# Notice this extends "SavedData" as well!
# It inherits the base save file features while adding properties specifically for managing pet timers and presence.
extends SavedData

# Registers "SavedPetManager" as a custom resource class in Godot.
class_name SavedPetManager

# ==========================================
# SAVED PET MANAGEMENT DATA
# ==========================================
# @export ensures these fields are serialized and written to disk when the game saves.

# Stores the species configuration/texture resource for the managed pet.
@export var pet_resource: petResource

# A Dictionary holding real-world or in-game timestamp data for when the pet leaves or exited the scene.
# Useful for calculating offline progress or time spent away!
@export var pet_exit_time: Dictionary

# Tracks how many hours the pet is scheduled to stay in the scene or facility.
@export var stay_duration_hours: int

# A boolean (true/false) flag tracking whether this pet has already been introduced to the player via a tutorial or cutscene.
@export var pet_introduced: bool
