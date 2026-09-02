# Extends "Control", making it a core UI layout node that coordinates experience display updates.
extends Control

# ==========================================
# NODE REFERENCES
# ==========================================
# Reference to the custom Label child node (which uses the label update script we commented earlier).
@onready var _petXpLabel = $PetXpLabel

# Retrieves the active pet node in the scene tree that belongs to the "Pet" node group.
@onready var _pet = get_tree().get_first_node_in_group("Pet")

# ==========================================
# INITIALIZATION
# ==========================================
# Called when the node enters the scene tree for the first time.
func _ready():
	# If a pet was found in the scene, connect its "xpGained" signal directly to the label's update function!
	if _pet:
		_pet.xpGained.connect(_petXpLabel.update_label)
		
	# Perform an initial display update using the pet's current level, current experience, and experience required.
	_petXpLabel.update_label(_pet.experience_level, _pet.experience, _pet.experience_required)
