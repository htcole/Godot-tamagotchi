# Extends "Control", making this the main Time/Clock controller UI node.
# Tracks in-game minutes, hours, and days, updates the HUD display, rotates a day/night wheel sprite,
# handles save/load persistence, and speeds up time progression when pets fall asleep.
extends Control

# ==========================================
# NODE REFERENCES
# ==========================================
# UI Labels updated with formatted game time string values.
@onready var daysLabel = get_node("%DaysLabel")
@onready var hoursLabel = get_node("%HoursLabel")
@onready var minutesLabel = get_node("%MinutesLabel")

# Sprite representing the day/night dial (sun/moon icon wheel).
@onready var sprite = $Sprite2D

# Reference to the main active pet node to monitor sleeping state changes.
@onready var pet = get_tree().get_first_node_in_group("Pet")

# ==========================================
# CONSTANTS & MATHEMATICAL RATIOS
# ==========================================
const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60

# Converts 1 in-game minute into a radiant/trigonometric fraction of a full 2π day cycle.
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

# Signal emitted every time an in-game minute ticks over (useful for scheduling pet needs/stamina drain).
signal time_tick(day: int, hour: int, minute: int)

# Current parsed time values.
var day: int
var hour: int
var minute: int

# Multiplier for how fast time moves in-game relative to delta time.
@export var INGAME_SPEED = 1.0

# Initial starting hour on scene boot (defaults to 12:00 PM noon).
@export var INITIAL_HOUR = 12:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR

# Internal raw float tracker representing total accumulated time.
var time = 0.0

# Tracks the last calculated minute to prevent redundant signal emissions.
var past_minute = -1.0

# ==========================================
# LIFECYCLE & PROCESS
# ==========================================
func _ready():
	# Initialize accumulated float time based on default INITIAL_HOUR.
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	
	# Connect signal listener to double speed when pets sleep.
	pet.pet_actions.sleepingToggled.connect(sleep_toggled)

# Increments elapsed game time every frame based on delta and speed settings.
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	recalculate_time()

# ==========================================
# SAVE & LOAD PERSISTENCE
# ==========================================
# Appends current clock state into save data array when saving the game.
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedTime.new()
	my_data.time = time
	saved_data.append(my_data)

# Restores total clock state when loading saved game data.
func on_load_game(saved_data: SavedData):
	time = saved_data.time

# ==========================================
# TIME RECALCULATION & UI
# ==========================================
# Converts accumulated float time into days, hours, and minutes.
func recalculate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	day = int(total_minutes / MINUTES_PER_DAY)
	
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	hour = int(current_day_minutes / MINUTES_PER_HOUR)
	minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	# Trigger updates only when a full in-game minute passes.
	if minute != past_minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)
		set_time()
		rotate_daytime_sprite(current_day_minutes)

# Rotates the sun/moon dial sprite based on minutes elapsed in the current day.
func rotate_daytime_sprite(current_day_minutes):
	if current_day_minutes != 0:
		# Maps 1440 minutes in a day to degree rotations around the dial axis.
		sprite.rotation_degrees = ((current_day_minutes / 360.0) * 90) + 160

# Formats time numbers into UI text string displays (e.g. "Day 1", "12:0").
func set_time():
	daysLabel.text = 'Day' + str(day + 1)
	hoursLabel.text = str(hour) + ':' + str(minute)

# ==========================================
# PET EVENT CALLBACKS
# ==========================================
# Speeds up time progression while the pet is sleeping so players don't wait as long.
func sleep_toggled(pet_state):
	if pet_state == Pet.PetState.SLEEPING:
		INGAME_SPEED = INGAME_SPEED * 2
	else:
		INGAME_SPEED = INGAME_SPEED / 2
