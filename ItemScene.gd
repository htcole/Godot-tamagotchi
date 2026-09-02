# Extends "Node2D", making this a 2D spatial world element that displays
# an inventory item sprite and can play interactive animations like bobbling.
extends Node2D

# ==========================================
# EXPORTED & NODE REFERENCES
# ==========================================
# Custom Resource representing the item data (contains texture, name, stats, etc.).
@export var item: Item

# Sprite2D node that visually renders the item in the world scene.
@onready var sprite = $Sprite2D

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Check if an Item resource is assigned in the Inspector.
	if item:
		sprite.texture = item.texture
		sprite.scale *= 2  # Scaled up for clearer visibility in-game
	else:
		print('error no item')

# ==========================================
# ANIMATION
# ==========================================
# Plays a dynamic bobbling/shaking animation loop using a sequential Tween.
func bobble_anim():
	var original_y = sprite.position.y
	var tween = get_tree().create_tween()
	
	for i in range(15):
		tween.tween_property(sprite, "position:y", original_y - 2, 0.1)
		tween.tween_property(sprite, "position:y", original_y + 2, 0.1)
		
	# Reset back to rest position when finished
	tween.tween_property(sprite, "position:y", original_y, 0.1)
