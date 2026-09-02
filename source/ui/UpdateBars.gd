# Extends "Control", making this the main Pet Stats HUD Overlay.
# Dynamically connects to the active pet's stats resource to display live progress bars, 
# percentage labels, and debug overall stat metrics.
extends Control

# ==========================================
# NODE REFERENCES (STAT BARS)
# ==========================================
# Uses Scene Unique Names (%) to reference ProgressBars for each pet need.
@onready var happinessBar = get_node("%HappinessBar")
@onready var hungerBar = get_node("%HungerBar")
@onready var hygieneBar = get_node("%HygieneBar")
@onready var funBar = get_node("%FunBar")
@onready var socialBar = get_node("%SocialBar")
@onready var tirednessBar = get_node("%TirednessBar")

# ==========================================
# NODE REFERENCES (DEBUG & LABELS)
# ==========================================
# Debug metric text labels displaying total cumulative points and average percentage across all needs.
@onready var statsTotalLabel = get_node("%StatsTotal")
@onready var statsAverageLabel = get_node("%StatsAverage")

# Text labels displaying numerical percentage strings next to each bar (e.g. "85%").
@onready var labelHappiness = get_node("%BarLabelHappiness")
@onready var labelHunger = get_node("%BarLabelHunger")
@onready var labelHygiene = get_node("%BarLabelHygiene")
@onready var labelFun = get_node("%BarLabelFun")
@onready var labelSocial = get_node("%BarLabelSocial")
@onready var labelTiredness = get_node("%BarLabelTiredness")

# Reference to the currently monitored pet node.
var pet: Node = null

# ==========================================
# INITIALIZATION & SETUP
# ==========================================
# Connects to RoomManager to listen for active pet changes on scene load.
func _ready():
	var room_manager = get_parent().get_node("RoomManager")
	room_manager.ActivePetChanged.connect(update_pet)
	
	# If a pet was already assigned before ready completed, wait for it to be ready and sync data.
	if pet:
		await pet.ready
		connect_pet_signals()
		update()

# Called whenever the player switches focus between different pets in the sanctuary.
func update_pet(new_pet: Node):
	# Safely disconnect signals from the previous pet before swapping.
	if pet:
		disconnect_pet_signals()
		
	pet = new_pet
	connect_pet_signals()
	update()

# ==========================================
# SIGNAL BINDING
# ==========================================
# Binds HUD update functions directly to the active pet's stat change signals.
func connect_pet_signals():
	pet.pet_stats.hungerChanged.connect(update_hunger)
	pet.pet_stats.happinessChanged.connect(update_happiness)
	pet.pet_stats.hygieneChanged.connect(update_hygiene)
	pet.pet_stats.funChanged.connect(update_fun)
	pet.pet_stats.socialChanged.connect(update_social)
	pet.pet_stats.tirednessChanged.connect(update_tiredness)
	pet.pet_stats.totalStatsChanged.connect(update_stats_total)

# Safely unbinds stat change signals when switching active pets.
func disconnect_pet_signals():
	pet.pet_stats.hungerChanged.disconnect(update_hunger)
	pet.pet_stats.happinessChanged.disconnect(update_happiness)
	pet.pet_stats.hygieneChanged.disconnect(update_hygiene)
	pet.pet_stats.funChanged.disconnect(update_fun)
	pet.pet_stats.socialChanged.disconnect(update_social)
	pet.pet_stats.tirednessChanged.disconnect(update_tiredness)
	pet.pet_stats.totalStatsChanged.disconnect(update_stats_total)

# Refresh all progress bars and text labels to match current pet values.
func update():
	update_hunger(pet.pet_stats.hunger)
	update_happiness(pet.pet_stats.happiness)
	update_hygiene(pet.pet_stats.hygiene)
	update_fun(pet.pet_stats.fun)
	update_social(pet.pet_stats.social)
	update_tiredness(pet.pet_stats.tiredness)
	update_stats_total(pet.pet_stats.total_stats)

# ==========================================
# UI UPDATE CALLBACKS
# ==========================================
# Updates hunger bar visual value (clamped at minimum 10 for bar fill visibility) and text label.
func update_hunger(value):
	hungerBar.value = max(10, value)
	labelHunger.text = str(value) + '%'

# Updates happiness bar visual value and text label.
func update_happiness(value):
	happinessBar.value = max(10, value)
	labelHappiness.text = str(value) + '%'

# Updates hygiene bar visual value and text label.
func update_hygiene(value):
	hygieneBar.value = max(10, value)
	labelHygiene.text = str(value) + '%'

# Updates fun bar visual value and text label.
func update_fun(value):
	funBar.value = max(10, value)
	labelFun.text = str(value) + '%'

# Updates social bar visual value and text label.
func update_social(value):
	socialBar.value = max(10, value)
	labelSocial.text = str(value) + '%'

# Updates tiredness bar visual value and text label.
func update_tiredness(value):
	tirednessBar.value = max(10, value)
	labelTiredness.text = str(value) + '%'

# Updates total cumulative stats debug label and triggers average calculation.
func update_stats_total(value):
	statsTotalLabel.text = 'total:' + str(value)
	update_stats_average(value)

# Calculates and displays average percentage across all 6 core needs.
func update_stats_average(value):
	statsAverageLabel.text = 'average:' + str(value / 6)
