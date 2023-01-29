extends Sprite2D

const drop_speed = 100

enum STATES { ready, armed, falling, exploded }

signal bomb_exploded

@onready var drop_sound = $"Drop sound"

var state
var target_position: Vector2

func _ready():
	state = STATES.ready


func _process(delta):
	match state:
		STATES.ready, STATES.exploded:
			return

		STATES.armed:
			if global_position.x > target_position.x:
				state = STATES.falling
				global_position.x = target_position.x
				drop_sound.play()
				
		STATES.falling:
			if global_position.y > 160:
				state = STATES.exploded
				emit_signal("bomb_exploded")
			else:
				global_position.y += drop_speed * delta
		

func drop():
	rotation_degrees = 90
	# Snap to next 100 / 8:
	
	var x_offset = snapped(global_position.x - 100, 8)
	target_position = Vector2(100 + x_offset, 0)
	state = STATES.armed


func rearm(pos: Vector2):
	rotation_degrees = 0
	global_position = pos
	state = STATES.ready
