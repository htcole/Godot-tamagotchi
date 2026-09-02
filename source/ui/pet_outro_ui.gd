# Extends "Control", making this a popup modal UI card that displays the guest's 
# exit checkout summary, review score, star rating, and animates coin rewards!
extends Control

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Uses Scene Unique Names (%) to reference UI components across the layout.
@onready var nameLabel = get_node("%NameLabel")
@onready var animalLabel = get_node("%AnimalLabel")
@onready var stayLabel = get_node("%StayLabel")
@onready var petImage = get_node("%PetImage")
@onready var statsLabel = get_node("%StatsLabel")
@onready var reviewLabel = get_node("%ReviewLabel")
@onready var coinsLabel = get_node("%CoinsLabel")
@onready var claimButton = get_node("%ClaimButton")

# Retrieves an array of all star icon textures inside the StarsContainer for rating displays.
@onready var stars = get_node("%StarsContainer").get_children()

# Preloads the physical Coin object scene spawned for reward animations.
@onready var coinScene = preload("res://source/objects/coin.tscn")

# Reference to the main HUD coin balance display node where animated coins fly to.
@onready var coinDisplay = get_tree().get_first_node_in_group("CoinDisplay")

# ==========================================
# CONFIGURATION VARIABLES
# ==========================================
# Color tint used to dim unearned review stars.
var unfilledColor = Color(0.3, 0.3, 0.3)

# Amount of coin currency awarded for this pet's stay.
var coins_amount: int

# Random pixel offset applied when spawning coins over the claim button.
var SPAWN_OFFSET = 10

# Delay (in seconds) between individual coin animation spawns.
var coin_delay = 0.3

# ==========================================
# CHECKOUT DATA INITIALIZATION
# ==========================================
# Populates UI metrics with data from the pet's stay dictionary and pauses world time.
func set_pet_info(pet_details):
	coins_amount = pet_details['coins']
	nameLabel.text = 'Name: ' + pet_details['name']
	animalLabel.text = 'Animal: ' + str(pet_details['animal'])
	stayLabel.text = 'Stay Duration: ' + str(pet_details['days']) + 'Days and ' + str(pet_details['hours']) + 'Hours.'
	petImage.texture = pet_details['image']
	statsLabel.text = 'Average stats:' + str(pet_details['stats']) + '%'
	reviewLabel.text = 'Review: ' + pet_details['review']
	coinsLabel.text = 'Coins Rewarded:' + str(pet_details['coins'])
	
	set_star_rating(pet_details['star_rating'])
	
	# Pause time during checkout summary review.
	get_tree().paused = true

# Sets star icons visual state by dimming unearned stars using modulate.
func set_star_rating(rating: int):
	rating = clamp(rating, 0, stars.size())
	for i in range(stars.size()):
		var star = stars[i]
		if i >= rating:
			star.modulate = unfilledColor

# ==========================================
# COIN ANIMATION & REWARD SYSTEM
# ==========================================
# Instantiates a 2D coin scene positioned near the claim button with randomized jitter.
func instance_coin():
	var coin = coinScene.instantiate()
	var button_size = claimButton.size
	
	# Center position over button + slight randomized scatter.
	coin.global_position = Vector2(claimButton.global_position.x, claimButton.global_position.y) + button_size/2 + Vector2(randi_range(-SPAWN_OFFSET, SPAWN_OFFSET), randi_range(-SPAWN_OFFSET, SPAWN_OFFSET))
	
	get_parent().add_child(coin)
	return coin

# Tweens spawned coins sequentially from the button to the UI coin counter HUD.
func animation_tween(coins, final_pos):
	for i in range(coins):
		var coin = instance_coin()
		var tween = get_tree().create_tween()
		
		# Smoothly slide coin to the coin balance icon on the HUD over 0.8 seconds.
		tween.tween_property(coin, "global_position", final_pos, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(_coin_tween_finished)
		
		# Wait for the last coin's movement before completing.
		if i == coins - 1:
			await tween.finished
			
		# Pause briefly before spawning the next coin (accelerates delay over time for satisfying burst effect).
		await get_tree().create_timer(coin_delay).timeout
		coin_delay *= 0.9
	return

# Increments global currency as each animated coin reaches the target destination.
func _coin_tween_finished():
	Global.coins += 1

# ==========================================
# BUTTON HANDLERS
# ==========================================
# Called when player clicks "Claim Reward": hides window, unpauses, animates coins, and frees node.
func _on_continue_button_pressed():
	self.visible = false
	get_tree().paused = false
	
	# Calculate target coordinates on the HUD coin balance counter.
	var coin_size = coinDisplay.sprite.texture.get_size()
	var final_global_pos = coinDisplay.global_position - coin_size/2
	
	# Run animated coin sequence before destroying this popup.
	await animation_tween(coins_amount, final_global_pos)
	queue_free()
