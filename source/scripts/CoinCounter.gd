# This script extends "Marker2D", positioning a visual coin display/counter 
# at a specific location in 2D space.
extends Marker2D

# ==========================================
# NODE REFERENCES
# ==========================================
# Points to the Label node that displays the numerical coin count.
@onready var coinLabel = $CoinCounter

# Points to the Sprite2D node that displays the coin icon graphic.
@onready var sprite = $Sprite2D

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Connects to the global "coinsChanged" signal from the Global singleton.
	# Whenever coins are added or spent anywhere in the game, update_counter() runs automatically!
	Global.coinsChanged.connect(update_counter)
	
	# Set the initial text display to match the starting coin value in Global.
	update_counter(Global.coins)

# ==========================================
# DISPLAY UPDATES
# ==========================================
# Called automatically when Global.coinsChanged emits. Converts the coin integer to text.
func update_counter(value):
	coinLabel.text = str(value)
