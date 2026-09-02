# Extends "Control", making this a user interface component (e.g. pop-up modal or dialog card)
# used to display detailed check-in information for a newly arrived pet.
extends Control

# ==========================================
# NODE REFERENCES
# ==========================================
# Uses unique node names (%NameLabel, %AnimalLabel, etc.) to reliably grab scene nodes
# regardless of where they are positioned in the scene hierarchy.
@onready var nameLabel = get_node("%NameLabel")
@onready var animalLabel = get_node("%AnimalLabel")
@onready var stayLabel = get_node("%StayLabel")
@onready var petImage = get_node("%PetImage")

# ==========================================
# POPUP INITIALIZATION
# ==========================================
# Populates the UI elements with pet dictionary details and pauses game world processing.
func set_pet_info(pet_details):
	# Set text fields using key-value pairs from the pet_details dictionary.
	nameLabel.text = 'Name: ' + pet_details['name']
	animalLabel.text = 'Animal: ' + str(pet_details['animal'])
	stayLabel.text = 'Stay Duration: ' + str(pet_details['days']) + 'Days and ' + str(pet_details['hours']) + 'Hours.'
	
	# Set the pet's sprite/portrait preview texture.
	petImage.texture = pet_details['image']
	
	# Pause gameplay so the player can review incoming guest details without time passing in the background.
	get_tree().paused = true

# ==========================================
# BUTTON HANDLERS
# ==========================================
# Called when the player presses the "Continue" button to acknowledge the pet details.
func _on_continue_button_pressed():
	# Unpause the game world so time and animations resume.
	get_tree().paused = false
	
	# Destroy this modal card instance to clean up memory and remove it from the screen.
	queue_free()
