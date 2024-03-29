extends Node2D

@onready var roof_tile = preload("res://roof.tscn")
@onready var floor_tile = preload("res://floor.tscn")
@onready var floor_base = $"FloorBase"

var rng = RandomNumberGenerator.new()

var bottom = Vector2.ZERO

signal house_built
signal house_destroyed

var floors: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	var sprite_num = rng.randi_range(0, 1)
	var additional_floors = rng.randi_range(4, 8)
	floors = 2 + additional_floors
	
	bottom = Vector2(0, floor_base.position.y + 8 * additional_floors)

	for floor_num in additional_floors + 2:
		var floor_block = floor_tile.instantiate()
		floor_block.frame = sprite_num
		floor_block.position.y = bottom.y - 8 * floor_num
		add_child(floor_block)
		await get_tree().create_timer(0.025).timeout
	var roof_block = roof_tile.instantiate()
	roof_block.position.y = bottom.y - 8 * (additional_floors + 2)
	roof_block.frame = sprite_num
	add_child(roof_block)

	emit_signal("house_built")
	
	
func _process(_delta):
	if floors == 0:
		emit_signal("house_destroyed")
		queue_free()
		
# Place snapping bottom part
func place_at(pos: Vector2):
	global_position = pos - bottom
