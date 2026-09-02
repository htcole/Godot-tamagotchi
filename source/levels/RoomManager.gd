# This script manages the rooms in your sanctuary/game, switching active rooms,
# adding newly purchased rooms, and coordinating saving/loading for all rooms and their pets.
extends Node

# ==========================================
# NODE REFERENCES & PRELOADS
# ==========================================
# Button UI used to cycle/toggle between available rooms.
@onready var room_toggle_button = $Button

# Parent container node in the scene tree that holds all room nodes as children.
@onready var roomContainer = get_parent().get_node("RoomContainer")

# Preloads the scene file template for instantiating new rooms when purchased or loaded.
@onready var roomScene = preload("res://source/levels/room.tscn")

# ==========================================
# STATE & VARIABLES
# ==========================================
# Flag to prevent multiple pets from triggering exit/enter animations simultaneously in PetGuestManager.
var queue_processing = false

# Reference to the room currently active/visible on screen.
var current_room: Node = null

# List storing references to all created room nodes.
var rooms: Array = []

# Reference to the pet residing inside the active room.
var current_pet: Node = null

# ==========================================
# SIGNALS
# ==========================================
# Emitted whenever the player switches rooms so other UI nodes know which pet is now active.
signal ActivePetChanged(pet)

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Gather all existing room nodes located under roomContainer.
	rooms = roomContainer.get_children()
	
	# Display the first room by default if any exist.
	if rooms.size() > 0:
		switch_to_room(rooms[0])
		
	# Hide the room toggle button if there is only 1 room (no other room to switch to!).
	if rooms.size() >= 1:
		room_toggle_button.visible = false

# ==========================================
# SAVE / LOAD SYSTEM INTEGRATION
# ==========================================
# Called by SaveManager when writing save data to disk.
func on_save_game(saved_data: Array[SavedData]):
	# Create a new SavedRoomInfo resource to hold our snapshot.
	var my_data = SavedRoomInfo.new()
	
	# Record active room index and total count.
	my_data.current_room_index = rooms.find(current_room)
	my_data.total_rooms = rooms.size()
	
	# Loop through every room to collect save snapshots for both its manager and its pet.
	for room in rooms:
		var pet_manager = room.get_node("GuestPetManager")
		var pet = room.get_node("Pet")
		my_data.pets_manager_info.append(pet_manager.get_pet_manager_save_data())
		my_data.pets_info.append(pet.get_pet_save_data())
		
	# Append this room snapshot into the save data array.
	saved_data.append(my_data)

# Hook called before loading game state (left available for pre-load cleanup if needed).
func on_before_load_game():
	pass

# Called by SaveManager when restoring saved data from disk.
func on_load_game(saved_data: SavedData):
	# Instantiate missing rooms if the saved game has more rooms than currently exist in the scene.
	while saved_data.total_rooms > rooms.size():
		add_room()
	
	# Restore saved manager and pet data for each room.
	for i in range(saved_data.pets_info.size()):
		var room = rooms[i]
		var pet_manager = room.get_node("GuestPetManager")
		var pet = room.get_node("Pet")
		pet_manager.update_to_save_data(saved_data.pets_manager_info[i])
		pet.update_to_save_data(saved_data.pets_info[i])

# ==========================================
# ROOM SWITCHING LOGIC
# ==========================================
# Switches visibility to the target room node and updates the active pet reference.
func switch_to_room(room: Node):
	if current_room:
		current_room.visible = false
	current_room = room
	current_room.visible = true
	update_active_pet()

# Helper function to switch rooms using an array index (e.g. 0 for Room 1, 1 for Room 2).
func switch_to_room_by_index(index: int):
	if index >= 0 and index < rooms.size():
		switch_to_room(rooms[index])

# Updates the current_pet reference to match the pet inside the active room and emits ActivePetChanged.
func update_active_pet():
	if current_room:
		current_pet = current_room.get_node("Pet")
		ActivePetChanged.emit(current_pet)

# ==========================================
# UI & ROOM PURCHASING HANDLERS
# ==========================================
# Cycles to the next room when the UI toggle button is clicked (loops back to room 0 at the end).
func _on_button_pressed():
	var current_room_index = rooms.find(current_room)
	var next_room_index: int
	if current_room_index == rooms.size() - 1:
		next_room_index = 0
	else:
		next_room_index = current_room_index + 1
	switch_to_room_by_index(next_room_index)

# Call this function when the player buys a new room expansion.
func room_purchased():
	add_room()

# Spawns a new room instance from roomScene and appends it to the room list and scene tree.
func add_room():
	var room = roomScene.instantiate()
	room.name = 'Room' + str(rooms.size() + 1)
	rooms.append(room)
	roomContainer.add_child(room)
	
	# Make the room toggle button visible now that more than one room exists.
	if !room_toggle_button.visible:
		room_toggle_button.visible = true
