# Notice this extends "SavedData" instead of standard "Resource"!
# This means SavedGlobal inherits (gains) all features of SavedData while adding global game-wide metrics 
# (like total economy, visitor counts, reviews, and inventory items).
extends SavedData

# Registers "SavedGlobal" as a custom resource class in Godot.
class_name SavedGlobal

# ==========================================
# ECONOMY STATS
# ==========================================
# @export ensures these numbers are saved to disk when the game saves.
@export var coins: int
@export var totalCoinsEarned: int
@export var totalCoinsSpent: int

# ==========================================
# VISITOR & PARK/PET METRICS
# ==========================================
# Tracks visitors who visit your pet or sanctuary.
@export var visitors: Array
@export var totalVisitors: int
@export var uniqueVisitors: Array
@export var totalUniqueVisitors: int

# Keeps track of the overall satisfaction score across visitors/pets.
@export var averageHappiness: int

# ==========================================
# REVIEWS & INVENTORY
# ==========================================
# Stores feedback or reviews left by visitors.
@export var reviewsInfo: Array

# Array[InvSlot] is a typed array that strictly holds a list of InvSlot resources 
# (representing items saved in the player's inventory grid).
@export var inv_slots: Array[InvSlot]
