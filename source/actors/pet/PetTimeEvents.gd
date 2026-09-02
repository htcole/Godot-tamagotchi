# This script handles all time-based events for the pet (stat decay over time, sleeping recovery, and periodic passive XP).
# It inherits from Node because it operates strictly in the background as a logic manager.
extends Node

# ==========================================
# NODE REFERENCES
# ==========================================
# get_parent() grabs the main Pet node directly above this one in the Scene Tree.
@onready var pet = get_parent()

# Finds the main Time UI/Clock manager node using Godot's Group system.
@onready var timeUI = get_tree().get_first_node_in_group("TimeUI")

# ==========================================
# TIME INTERVAL CONFIGURATION
# ==========================================
# These constants set how many in-game minutes must pass before a specific event triggers.
# Modifying these numbers allows you to easily balance how quickly your pet gets hungry, tired, dirty, etc.
const HUNGER_INTERVAL = 10
const HAPPINESS_INTERVAL = 15
const HYGINE_INTERVAL = 30
const FUN_INTERVAL = 15
const SOCIAL_INTERVAL = 30
const TIRED_INTERVAL = 45
const POOP_INTERVAL = 30
const XP_GAIN_INTERVAL = 10

# ==========================================
# INITIALIZATION
# ==========================================
func _ready():
	# Connects the TimeUI clock's `time_tick` signal to the `process_time_events` function below.
	# Every time an in-game minute ticks forward, `process_time_events` will automatically run.
	timeUI.time_tick.connect(process_time_events)

# ==========================================
# TIME EVENT PROCESSING
# ==========================================
# This function receives the current game day, hour, and minute whenever time ticks.
func process_time_events(_day, _hour, minute):
	# --------------------------------------
	# 1. SLEEPING LOGIC
	# --------------------------------------
	# If the pet is currently asleep, reduce its tiredness level every minute.
	if pet.state == pet.PetState.SLEEPING:
		pet.pet_stats.tiredness -= 1
		pet.pet_actions.reaction_popup('sick') # Displays sleeping reaction icon
		
		# Once tiredness reaches 0, the pet is fully rested and wakes up automatically.
		if pet.pet_stats.tiredness == 0:
			pet.pet_actions.toggle_sleep()

	# NOTE ON MODULO OPERATOR (%):
	# `minute % INTERVAL == 0` checks if the current minute is evenly divisible by that interval number.
	# For example, `minute % 10 == 0` will trigger at minute 0, 10, 20, 30, 40, and 50.

	# --------------------------------------
	# 2. HUNGER & FEED COUNTER
	# --------------------------------------
	if minute % HUNGER_INTERVAL == 0:
		pet.pet_stats.hunger += 5          # Hunger increases (higher = hungrier)
		pet.pet_actions.feed_counter -= 1   # Gradually resets overfeed spam penalty

	# --------------------------------------
	# 3. HAPPINESS & PET COUNTER
	# --------------------------------------
	if minute % HAPPINESS_INTERVAL == 0:
		pet.pet_stats.happiness -= 5       # Happiness gradually decays over time
		pet.pet_actions.pet_counter -= 1    # Gradually resets over-petting spam penalty

	# --------------------------------------
	# 4. HYGIENE DECAY (DYNAMIC INTERVAL)
	# --------------------------------------
	# The hygiene interval shrinks by 20% for every poop currently on screen, making the pet dirty faster!
	# `max(..., 5)` ensures the decay interval never drops below a minimum speed cap of 5 minutes.
	var dynamic_hygiene_interval = int(max(HYGINE_INTERVAL - (HYGINE_INTERVAL * pet.pet_actions.poop_counter * 0.2), 5))
	if minute % dynamic_hygiene_interval == 0:
		pet.pet_stats.hygiene -= 5

	# --------------------------------------
	# 5. FUN & SOCIAL DECAY
	# --------------------------------------
	if minute % FUN_INTERVAL == 0:
		pet.pet_stats.fun -= 5

	if minute % SOCIAL_INTERVAL == 0:
		pet.pet_stats.social -= 5

	# --------------------------------------
	# 6. TIREDNESS (AWAKE ONLY)
	# --------------------------------------
	# Increases tiredness over time, but ONLY if the pet isn't currently sleeping.
	if minute % TIRED_INTERVAL == 0 and pet.state != pet.PetState.SLEEPING:
		pet.pet_stats.tiredness += 5

	# --------------------------------------
	# 7. POOP CHANCE & PASSIVE XP
	# --------------------------------------
	if minute % POOP_INTERVAL == 0:
		pet.pet_actions.random_poop_chance()

	if minute % XP_GAIN_INTERVAL == 0:
		# Rewards the player with passive XP based on how well-maintained the pet's average stats are.
		pet.gain_xp_based_on_stats(pet.pet_stats.average_stats)
