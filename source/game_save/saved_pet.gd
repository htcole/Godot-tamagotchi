# Notice this extends "SavedData" instead of standard "Resource"!
# This means SavedPet inherits from SavedData while adding fields specific to saving a pet's state.
extends SavedData

# Registers "SavedPet" as a custom resource class in Godot.
class_name SavedPet

# ==========================================
# PET IDENTITY / RESOURCE
# ==========================================
# @export ensures these fields are saved to disk when the game saves.
# Stores the species data (texture, animal type, default name) from petResource.
@export var pet_resource: petResource

# ==========================================
# SAVED PET STATS
# ==========================================
# Preserves the pet's core Needs/Stats at the time of saving.
@export var hunger: int
@export var happiness: int
@export var hygiene: int
@export var fun: int
@export var social: int
@export var tiredness: int

# Historical stat-tracking data used to calculate long-term average health.
@export var cumulative_avg_stats: float
@export var update_stats_count: int

# ==========================================
# SAVED ACTION COUNTERS
# ==========================================
# Tracks spam/limit counters so penalties persist across game sessions.
@export var feed_counter: int
@export var pet_counter: int
@export var poop_counter: int
