# This script manages all of the pet's core Needs/Stats (hunger, happiness, hygiene, etc.).
# It inherits from Node because it's a data manager and doesn't need 2D visuals or movement.
extends Node

# Registers "PetStats" as a custom class name so other scripts can recognize it.
class_name PetStats

# get_parent() grabs the main Pet node directly above this one in the Scene Tree.
@onready var pet = get_parent()

# ==========================================
# SIGNALS
# ==========================================
# Signals broadcast stat changes whenever they occur. 
# Your UI (like health bars or stat meters) listens to these to update on-screen levels automatically.
signal hungerChanged(value)
signal happinessChanged(value)
signal hygieneChanged(value)
signal funChanged(value)
signal socialChanged(value)
signal tirednessChanged(value)
signal totalStatsChanged(value)

# ==========================================
# STAT VARIABLES & SETTERS
# ==========================================
# The maximum value any individual stat can reach.
var MAX_STAT = 100

# An array containing the names of all managed stats.
var stats = ['happiness', 'hunger', 'hygiene', 'fun', 'social', 'tiredness']

# Setters (`set(new_value):`) automatically execute whenever a variable is modified.
# `clamp(value, min, max)` ensures stats never drop below 0 or exceed 100.

@export var happiness: int = 40:
	set(new_value):
		happiness = clamp(new_value, 0, MAX_STAT)
		update_total_stats() # Recalculate average pet health
		emit_signal('happinessChanged', happiness) # Notify UI
		
@export var hunger: int = 50:
	set(new_value):
		hunger = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('hungerChanged', hunger)
		
@export var hygiene: int = 80:
	set(new_value):
		# Special Clamp: Max hygiene is reduced if poop is present on screen.
		# For example, 2 poops cap max hygiene at 100 - (2 * 10) = 80.
		hygiene = clamp(new_value, 0, (MAX_STAT - min((pet.pet_actions.poop_counter * 10), MAX_STAT)))
		update_total_stats()
		emit_signal('hygieneChanged', hygiene)
		
@export var fun: int = 40:
	set(new_value):
		fun = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('funChanged', fun)

@export var social: int = 40:
	set(new_value):
		social = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('socialChanged', social)
		
@export var tiredness: int = 40:
	set(new_value):
		tiredness = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('tirednessChanged', tiredness)
		
@export var total_stats: int:
	set(new_value):
		total_stats = new_value
		emit_signal('totalStatsChanged', total_stats)

# ==========================================
# STAT TRACKING & METRICS
# ==========================================
var average_stats : int
var cumulative_avg_stats = 0.0 # Running total of all averages logged over time
var update_stats_count = 0    # How many times stats have been logged

# Calculates combined pet overall well-being across all 6 stats.
func update_total_stats():
	# Hunger and Tiredness are "negative" stats (higher numbers = bad),
	# so we invert them with (MAX_STAT - value) so 100 always represents perfect health.
	total_stats = happiness + (MAX_STAT - hunger) + hygiene + fun + social + (MAX_STAT - tiredness)
	
	# Divide total score by the number of stats (6) to get current average health score.
	average_stats = round(total_stats / stats.size())
	
	# Accumulate historical data to evaluate long-term care quality.
	cumulative_avg_stats += average_stats
	update_stats_count += 1

# Calculates the pet's lifetime average health score across its entire lifetime.
func get_overall_average_stats() -> float:
	# Prevent division by zero error if stats haven't been updated yet.
	if update_stats_count == 0:
		return 0
	return cumulative_avg_stats / update_stats_count

# ==========================================
# RESET FUNCTIONS
# ==========================================
# Fully resets tracking history and assigns fresh random stats to the pet.
func reset_stats():
	reset_average_stat_tracking()
	reset_and_randomize_stats()
	
# Clears historical average tracking (e.g. when starting a new pet generation).
func reset_average_stat_tracking():
	cumulative_avg_stats = 0.0
	update_stats_count = 0
	# Log an initial baseline snapshot
	update_total_stats()
	
# Assigns fresh randomized values to all stats (used when acquiring/hatching a new pet).
func reset_and_randomize_stats():
	# Multiplies randi_range(1,8) by 5 to give clean step increments (5, 10, 15... up to 40).
	happiness = randi_range(1,8) * 5
	hunger = MAX_STAT - randi_range(1,8) * 5
	hygiene = randi_range(1,8) * 5
	fun = randi_range(1,8) * 5
	social = randi_range(1,8) * 5
	tiredness = MAX_STAT - randi_range(1,8) * 5
