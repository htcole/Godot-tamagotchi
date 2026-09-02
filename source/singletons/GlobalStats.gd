# This script inherits from "Global.gd", extending its functionality.
# It can be used to add specialized stat calculations or extra singleton features
# on top of your core Global data manager.
extends "res://source/singletons/Global.gd"

# ==========================================
# NODE REFERENCES & LOCAL VARIABLES
# ==========================================
# @onready initializes this variable right after the node enters the scene tree.
@onready var lol = 12

# ==========================================
# STAT FUNCTIONS
# ==========================================
# Example extended function to process or display advanced global player statistics.
func global_stats_function():
	print("Global stats function called in GlobalStats.gd")
