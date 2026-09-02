# Extends "CanvasLayer" so that the computer UI renders on top of all 2D game elements,
# regardless of camera position or room scrolling.
extends CanvasLayer

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Grabs reference to the main action buttons HUD to listen for the "openComputer" signal.
@onready var buttons_ui = get_tree().get_first_node_in_group("ButtonsUI")

# AnimationPlayer controlling computer opening/closing zoom animations.
@onready var anim_player = $AnimationPlayer

# Sub-page references inside the computer UI interface.
@onready var desktopPage = $ComputerPanel/Desktop
@onready var foodShopPage = $ComputerPanel/FoodShop
@onready var statsViewPage = $ComputerPanel/StatsView
@onready var ReviewsViewPage = $ComputerPanel/ReviewsView
@onready var roomExpandPage = $ComputerPanel/RoomExpandShop
@onready var backButton = $ComputerPanel/ComputerButtons/BackButton

# ==========================================
# STATE & PAGE TRACKING
# ==========================================
var computer_active = false

# Array storing references to computer sub-pages.
@onready var pages = [desktopPage, foodShopPage, statsViewPage, ReviewsViewPage]

# Tracks which sub-page is currently visible on the computer monitor (defaults to the home Desktop page).
@onready var current_page: Control = desktopPage

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Connect to the "openComputer" signal emitted when the player clicks the computer icon on the action bar.
	buttons_ui.openComputer.connect(open_computer)
	
	# Hide the "Back" button by default when on the main desktop page.
	backButton.visible = false

# ==========================================
# COMPUTER OPEN / CLOSE LOGIC
# ==========================================
# Opens the computer interface, pauses background game processing, and plays the zoom-in animation.
func open_computer():
	get_tree().paused = true
	self.visible = true
	anim_player.play("ZoomIn")

# Power button click handler: closes the computer interface, resumes time, and plays zoom-out animation.
func _on_power_button_pressed():
	anim_player.play("ZoomOut")
	get_tree().paused = false
	await anim_player.animation_finished
	self.visible = false

# ==========================================
# SUB-PAGE NAVIGATION LOGIC
# ==========================================
# Handles switching between computer apps/pages with transition animations.
func switch_page(page_to_show):
	page_to_show.visible = true
	
	# Play zoom-in animation on the incoming page if it has its own AnimationPlayer node.
	if page_to_show.get("anim_player"):
		page_to_show.anim_player.play("ZoomIn")
		await page_to_show.anim_player.animation_finished
		
	# Play zoom-out animation on the previous page if present.
	if current_page.get("anim_player"):
		current_page.anim_player.play("ZoomOut")
		await current_page.anim_player.animation_finished
		
	# Show the back button only when navigating away from the home Desktop screen.
	backButton.visible = (page_to_show != desktopPage)
	current_page.visible = false
	current_page = page_to_show

# ==========================================
# APP / MENU BUTTON HANDLERS
# ==========================================
# Opens the food shop app.
func _on_shop_button_pressed():
	switch_page(foodShopPage)

# Returns to the main desktop home page.
func _on_back_button_pressed():
	switch_page(desktopPage)

# Opens the sanctuary statistics app and updates its displayed metrics.
func _on_stats_button_pressed():
	switch_page(statsViewPage)
	statsViewPage.update()

# Opens the guest review app and populates historical review ratings.
func _on_reviews_button_pressed():
	switch_page(ReviewsViewPage)
	ReviewsViewPage.update()

# Opens the room expansion store page to allow purchasing additional rooms.
func _on_rooms_button_pressed():
	switch_page(roomExpandPage)
	roomExpandPage.update()
