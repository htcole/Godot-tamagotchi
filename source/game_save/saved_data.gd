# This script extends "Resource", meaning it acts as a custom data container rather than a visible scene node.
# It represents the master save file that holds ALL global data for a single save slot (like money, unlocked items, and saved pets).
extends Resource

# Registers "SavedData" as a custom class name so Godot can recognize and save/load this resource structure to disk.
class_name SavedData
