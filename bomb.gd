extends Sprite

const drop_speed = 100

var falling := false

var turning := true

signal bomb_exploded


func _ready():
	falling = false


func _process(delta):
	if turning:
		return
	
	if global_position.y > 160:
		falling = false	
		turning = false
		emit_signal("bomb_exploded")

	global_position.y += drop_speed * delta

		
func drop():
	falling = true
	
	rotation_degrees = 90
	# Snap to next 100 / 8:
	
	var x_offset = stepify(global_position.x - 104, 8)
	global_position.x = 100 + x_offset
	turning = false
