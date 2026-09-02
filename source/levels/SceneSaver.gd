# This script manages creating, saving, and loading your game's save file on disk.
# It acts as the central hub connecting all script-level save data to Godot's file system.
extends Node

# ==========================================
# CONSTANTS & REFERENCES
# ==========================================
# "user://" points to Godot's dedicated, platform-safe app storage folder on the player's device.
# `.tres` is a Godot Text Resource format used to store custom resources like `SavedGame`.
const SAVE_GAME_PATH := "user://savedgame.tres"

# References to managers needed during save/load operations.
@onready var roomManager = get_parent().get_node("RoomManager")
@onready var timeUI = get_parent().get_node("TimeUI")

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Ensures the save directory exists before trying to access or write files.
	verify_save_directory("user://")
	
	# Automatically loads progress if a save file already exists; otherwise starts fresh.
	if FileAccess.file_exists(SAVE_GAME_PATH):
		load_game()
	else:
		print('no save file, starting fresh.')

# ==========================================
# FILE SYSTEM HELPERS
# ==========================================
# Checks if the target folder exists on disk, and creates it recursively if missing.
func verify_save_directory(path: String) -> void:
	var dir_path = path.get_base_dir()
	var dir = DirAccess.open(dir_path)
		
	if dir == null:
		print("Failed to open directory: %s" % dir_path)
		return
		
	if dir.dir_exists(dir_path):
		print("Directory exists: %s" % dir_path)
	else:
		var result = dir.make_dir_recursive(dir_path)
		if result != OK:
			print("Failed to create directory: %s" % dir_path)
		else:
			print("Directory created: %s" % dir_path)

# ==========================================
# SAVE GAME LOGIC
# ==========================================
# Gathers save data from all registered systems and writes it to disk.
func save_game():
	# Safety check: prevents saving mid-transition when pets are entering/leaving rooms.
	if roomManager.queue_processing:
		print("cannot save now")
		return
		
	# Instantiate the master save resource container (`SavedGame.gd`).
	var saved_game: SavedGame = SavedGame.new()
	
	# Prepare a typed array to collect individual `SavedData` objects.
	var saved_data: Array[SavedData] = []
	
	# `call_group` broadcasts the "on_save_game" function to EVERY node assigned to the "SaveGroup" group.
	# Each node (RoomManager, TimeUI, Global) creates its own `SavedData` object and appends it to `saved_data`.
	get_tree().call_group("SaveGroup", "on_save_game", saved_data)
	
	# Pack all gathered data objects into the master container.
	saved_game.saved_data = saved_data
	
	# Save the entire `SavedGame` resource structure to the designated file path on disk.
	ResourceSaver.save(saved_game, SAVE_GAME_PATH)

# ==========================================
# LOAD GAME LOGIC
# ==========================================
# Reads the save file from disk and distributes data back to appropriate managers.
func load_game():
	# Safely load and cast the file resource back into a `SavedGame` object.
	var saved_game: SavedGame = SafeResourceLoader.load(SAVE_GAME_PATH) as SavedGame
	if saved_game == null:
		print("Failed to load saved game.")
		return
		
	# Loop through each `SavedData` item stored inside the loaded file.
	# `is` checks the exact resource class type to send the data to the correct manager!
	for saved_data in saved_game.saved_data:
		if saved_data is SavedRoomInfo:
			roomManager.on_load_game(saved_data)
		elif saved_data is SavedTime:
			timeUI.on_load_game(saved_data)
		elif saved_data is SavedGlobal:
			Global.on_load_game(saved_data)

# ==========================================
# UI & TIMER TRIGGERS
# ==========================================
# Manual Save Button press.
func _on_button_pressed():
	save_game()

# Manual Load Button press.
func _on_button_2_pressed():
	load_game()

# Autosave Timer trigger (e.g. saves automatically every few minutes).
func _on_timer_timeout():
	save_game()
