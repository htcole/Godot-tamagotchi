# Extends "Panel", making this an individual UI card component used to display a single 
# past guest's summary thumbnail (their pet portrait and star rating) inside the Reviews scroll list.
extends Panel

# ==========================================
# NODE REFERENCES
# ==========================================
# Grabs the PetImage TextureRect using Scene Unique Name (%) for reliable referencing.
@onready var petImage = get_node("%PetImage")

# Collects all star TextureRect nodes inside the StarsContainer node into an array.
@onready var stars = get_node("%StarsContainer").get_children()

# ==========================================
# CONFIGURATION
# ==========================================
# Color tint applied to darken unearned star textures (dark gray).
var unfilledColor = Color(0.3, 0.3, 0.3)

# ==========================================
# DATA POPULATION
# ==========================================
# Updates this card panel with review data passed in from ReviewsViewPage.gd.
func update(review):
	# Set the pet's sprite/portrait texture from the review dictionary.
	petImage.texture = review['image']
	
	# Light up or dim the star icons based on the numeric star rating.
	set_star_rating(review['star_rating'])

# Sets star icons visual state by applying a dark tint (modulate) to unearned stars.
func set_star_rating(rating: int):
	# Ensure rating value stays safely within range (0 to total number of star nodes).
	rating = clamp(rating, 0, stars.size())
	
	# Loop through every star node in the container.
	for i in range(stars.size()):
		var star = stars[i]
		# If star index is at or above the rating threshold, apply the dimmed color.
		if i >= rating:
			star.modulate = unfilledColor
