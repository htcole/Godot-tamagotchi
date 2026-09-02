# Extends "SavedData" to inherit base save resource functionality.
# This script specifically holds saved data related to game clock/time tracking.
extends SavedData

# Registers "SavedTime" as a custom resource class in Godot.
class_name SavedTime

# ==========================================
# SAVED TIME DATA
# ==========================================
# @export ensures this float value is saved to disk when the game saves.
# Stores total elapsed game time or clock state (e.g., total seconds/minutes elapsed in-game).
@export var time: float
