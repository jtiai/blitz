extends Node2D

enum states { INIT, STANDBY, RUN }

onready var skyscraper = preload("res://skyscraper.tscn")
onready var plane = $"Plane"
onready var bomb_attachment = $"Plane/Bomb Attachment"
onready var bomb = $"Bomb"
onready var descend_tween = $"Descend Tween"

var speed = 0

var descend_done = false

var state

# Called when the node enters the scene tree for the first time.
func _ready():
	state = states.INIT
	speed = 50
	descend_done = false
	bomb.global_position = bomb_attachment.global_position	
	setup_buildings()


func _process(delta):
	if state != states.RUN:
		return
		
	#plane.global_position.x += speed * delta
	if not descend_done and plane.global_position.x > 275:
		# Descend plane
		descend_done = true
		var source_height = plane.global_position.y
		var target_height = plane.global_position.y + 8
		descend_tween.interpolate_property(
			plane, 'global_position:y', source_height, target_height, 0.5, 
			Tween.EASE_OUT, Tween.TRANS_SINE
		)
		descend_tween.start()
		
	if plane.global_position.x > 335:
		# Wrap plane
		plane.global_position.x = -15
		descend_done = false
		
	if not bomb.falling:
		bomb.global_position = bomb_attachment.global_position
		
	if Input.is_action_just_pressed("drop_bomb"):
		bomb.drop()
		

func setup_buildings():
	var pos = Vector2(100, 156)
	for i in 16:
		var building = skyscraper.instance()
		add_child(building)
		building.place_at(pos)
		pos.x += 8
		yield(building, "house_built")
		yield(get_tree().create_timer(0.5), "timeout")
	state = states.RUN


func _on_Bomb_bomb_exploded():
	bomb.rotation_degrees = 0
	bomb.global_position = bomb_attachment.global_position
