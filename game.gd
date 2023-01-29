extends Node2D

enum states { INIT, STANDBY, RUN, CRASHED }

@onready var skyscraper = preload("res://skyscraper.tscn")
@onready var plane = $"Plane"
@onready var bomb_attachment = $"Plane/Bomb Attachment"
@onready var bomb = $"Bomb"
@onready var descend_tween = $"Descend Tween"
@onready var startup_tween = $"Startup Tween"
@onready var parallax = $"ParallaxBackground"
@onready var plane_flying_sound = $"Plane/Flying Sound"
@onready var plane_crash_sound = $"Plane/Crash Sound"
@onready var plane_crash_particles = $"Plane crash particles"
@onready var ui_game_over = $"UI/Game Over"
@onready var ui_stage_cleared = $"UI/Stage Cleared"

var speed = 0

var descend_done = false

var state
var houses: int = -1

func _ready():
	state = states.INIT
	speed = 50
	descend_done = false
	bomb.global_position = bomb_attachment.global_position
	plane_flying_sound.stream.loop_mode = 2
	plane_flying_sound.stream.loop_end -= 1
	plane_flying_sound.play()

	startup_tween.interpolate_property(
		plane, 'global_position', null, Vector2(20, 24), 8.0,
		Tween.EASE_OUT, Tween.TRANS_SINE
	)
	startup_tween.start()

	setup_buildings()


func _process(delta):
	parallax.scroll_offset.x -= 5 * delta

	if state == states.CRASHED and Input.is_action_just_pressed("drop_bomb"):
		get_tree().change_scene_to_file("res://title_screen.tscn")

	if state == states.STANDBY and (plane.global_position.x < 45 or plane.global_position.x > 190):
		# Roll plane to middle of the screen.
		plane.global_position.x += speed * delta
		if plane.global_position.x > 335:
			plane.global_position.x = -15


	if state != states.RUN:
		bomb.global_position = bomb_attachment.global_position  # Keep bomb with plane
		return

	plane.global_position.x += speed * delta
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

	if bomb.state in [bomb.STATES.ready, bomb.STATES.armed]:
		bomb.global_position = bomb_attachment.global_position

	if bomb.state == bomb.STATES.ready and Input.is_action_just_pressed("drop_bomb"):
		bomb.drop()


func setup_buildings():
	houses = 15
	var pos = Vector2(100, 156)
	for i in 15:
		var building = skyscraper.instantiate()
		building.connect("house_destroyed",Callable(self,"_on_house_destroyed"))
		add_child(building)
		building.place_at(pos)
		pos.x += 8
		await building.house_built
		await get_tree().create_timer(0.25).timeout
	state = states.RUN


func _on_Bomb_bomb_exploded():
	bomb.rearm(bomb_attachment.global_position)


func _on_Plane_collider_area_entered(area):
	if area.is_in_group("building"):
		state = states.CRASHED
		plane_flying_sound.stop()
		plane_crash_sound.play()
		plane.visible = false
		bomb.visible = false
		plane_crash_particles.global_position = plane.global_position
		plane_crash_particles.emitting = true
		ui_game_over.visible = true


func _on_house_destroyed():
	houses -= 1
	if houses == 0:
		ui_stage_cleared.visible = true
		descend_tween.interpolate_property(
			plane, 'global_position:y', null, 152, 5.0,
			Tween.EASE_OUT, Tween.TRANS_SINE
		)
		descend_tween.start()
		await descend_tween.finished
		state = states.STANDBY
		await get_tree().create_timer(4.0).timeout
		descend_tween.interpolate_property(
			plane, 'global_position', null, Vector2(350, 75), 5.0,
			Tween.EASE_OUT, Tween.TRANS_SINE
		)
		descend_tween.start()
		await descend_tween.finished
		plane.global_position = Vector2(-19, -13)

		ui_stage_cleared.visible = false

		state = states.INIT
		startup_tween.interpolate_property(
			plane, 'global_position', null, Vector2(20, 24), 8.0,
			Tween.EASE_OUT, Tween.TRANS_SINE
		)
		startup_tween.start()

		setup_buildings()
