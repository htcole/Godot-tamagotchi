# Extends "Control", making this the main controller for the Reviews View page 
# on the computer monitor interface. It dynamically populates guest feedback cards into a scrollable container.
extends Control

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Container node (VBoxContainer or GridContainer) inside the ScrollContainer where review cards are stacked.
@onready var reviewContainer = $ScrollContainer/ReviewsContainer

# Optional AnimationPlayer for UI transitions on this page.
@onready var anim_player = $AnimationPlayer

# Preloads the Review Thumbnail UI card scene instantiated for each completed guest review.
@onready var reviewThumbnail = preload("res://source/ui/review_thumbnail.tscn")

# Label displayed as fallback text ("No reviews yet!") when zero reviews exist.
@onready var noReviewsLabel = $ScrollContainer/ReviewsContainer/Label

# ==========================================
# STATE & CONSTANTS
# ==========================================
# Array holding instantiated review UI thumbnail nodes.
@onready var review_thumbnails: Array = []

# Local cache of reviews retrieved from Global memory.
var reviews: Array

# Naming convention and path constants for dynamic node instantiation.
var REVIEW_THUMBNAIL_NAME = 'ReviewThumbnail'
var REVIEW_CONTAINER_PATH = "ScrollContainer/ReviewsContainer"

# ==========================================
# INITIALIZATION & REFRESH
# ==========================================
func _ready():
	# Initial fetch and display of reviews on scene startup.
	update()

# Refreshes the review list by comparing local cache against Global.reviewsInfo.
func update():
	# Skip regeneration if review data hasn't changed since the last update.
	if (reviews == Global.reviewsInfo):
		return
		
	reviews = Global.reviewsInfo
	check_for_new_reviews()
	
	# Show "No Reviews" label only if there are zero reviews saved.
	noReviewsLabel.visible = reviews.size() == 0

# ==========================================
# DYNAMIC THUMBNAIL CREATION
# ==========================================
# Loops through global reviews and instantiates missing UI card nodes.
func check_for_new_reviews():
	for review in reviews:
		var review_index = reviews.find(review)
		# Only instantiate a card if one doesn't already exist for this index.
		if !get_review_thumbnail_node(review_index):
			create_review_thumbnail(review, review_index)

# Helper function to check if a review thumbnail node already exists at the given index.
func get_review_thumbnail_node(review_index):
	var node_name = REVIEW_THUMBNAIL_NAME + str(review_index)
	var node_path = REVIEW_CONTAINER_PATH + node_name
	if has_node(node_path):
		return get_node(node_path)
	else:
		return null

# Instantiates a review thumbnail scene, sets its data, and appends it to the scroll box.
func create_review_thumbnail(review, num):
	var review_thumbnail = reviewThumbnail.instantiate()
	review_thumbnail.name = REVIEW_THUMBNAIL_NAME + str(num)
	reviewContainer.add_child(review_thumbnail)
	
	# Pass review dictionary data into the thumbnail card component.
	review_thumbnail.update(review)
	review_thumbnails.append(review_thumbnail)
