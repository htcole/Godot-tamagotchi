# Extends "Resource" so that each item in your game (food, toys, shop goods)
# can be created and saved as an independent data file in Godot.
extends Resource

# Registers "Item" as a custom resource class in Godot.
# This lets you right-click in your FileSystem panel and pick "New Resource..." -> "Item".
class_name Item

# ==========================================
# EXPORTED ITEM PROPERTIES
# ==========================================
# @export makes these properties editable directly inside the Godot Inspector.

# The displayed display name of the item (e.g., "Apple", "Pet Toy").
@export var name: String = ""

# The 2D image/sprite texture used to show this item in the shop or inventory grid.
@export var texture: Texture2D

# The cost of purchasing this item in the shop.
@export var price: int

# ==========================================
# ITEM CATEGORIZATION
# ==========================================
# An enum (enumeration) defines item categories.
# Godot represents these as numbers internally (Item = 0, Food = 1, Test = 2).
enum ItemType { Item, Food, Test }

# Exposes a dropdown menu in the Inspector to select the category for this item.
@export var type: ItemType
