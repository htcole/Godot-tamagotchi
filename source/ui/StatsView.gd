# Extends "Control", making this the Analytics/Stats Page script on the computer monitor.
# Displays long-term sanctuary metrics (coins earned, spent, total visitors) with a typewriter text animation.
extends Control

# ==========================================
# NODE REFERENCES
# ==========================================
# Collects all Label nodes inside the StatsTextContainer into an array.
@onready var statsLabels: Array = $StatsTextContainer.get_children()

# Optional AnimationPlayer for UI view transitions.
@onready var anim_player = $AnimationPlayer

# Local helper reference variable for label iteration.
var label: Label

# ==========================================
# INITIALIZATION & LIFECYCLE
# ==========================================
# Called when this computer page node enters the scene tree.
func _ready():
	set_stats()

# Called whenever the player opens or updates the Stats view tab.
func update():
	hide_text()
	set_stats()
	animate_text()

# ==========================================
# DATA POPULATION
# ==========================================
# Reads global tracking variables and updates text strings for each statistics label.
func set_stats():
	statsLabels[0].text = 'Total Coins Earned: ' + str(Global.totalCoinsEarned)
	statsLabels[1].text = 'Total Coins Spent: ' + str(Global.totalCoinsSpent)
	statsLabels[2].text = 'Total Visitors: ' + str(Global.totalVisitors)
	statsLabels[3].text = 'Visitors: ' + str(Global.visitors)
	statsLabels[4].text = 'Total Unique Pets Visited: ' + str(Global.totalUniqueVisitors)

# Dynamically hides text across all labels by setting their visible character count to 0.
func hide_text():
	for statsLabel in statsLabels:
		statsLabel.visible_characters = 0

# ==========================================
# TYPEWRITER ANIMATION
# ==========================================
# Sequentially reveals characters one by one across each label for a computer terminal typing effect.
func animate_text():
	for statsLabel in statsLabels:
		# Reveal one character at a time with a 0.01s delay.
		for i in range(statsLabel.get_total_character_count()):
			statsLabel.visible_characters += 1
			await get_tree().create_timer(0.01).timeout
			
		# Brief pause before typing out the next line.
		await get_tree().create_timer(0.05).timeout
