extends Control

@onready var title_music = $"Title Music"
@onready var audio_tween = $"Audio Tween"
@onready var parallax = $"ParallaxBackground"
@onready var plane = $"Plane"
@onready var bomb = $"Plane/Bomb"
@onready var fade_to_black = $"CanvasLayer/FadeToBlack"
@onready var fade_to_black_tween = $"CanvasLayer/FadeToBlackTween"

var rng = RandomNumberGenerator.new()

var plane_dir = 50

func _ready():
	rng.randomize()
	title_music.volume_db = -80.0
	title_music.play()
	fade_to_black_tween.interpolate_property(fade_to_black, "color:a", 1.0, 0.0, 1.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	fade_to_black_tween.start()
	audio_tween.interpolate_property(title_music, "volume_db", -80.0, -10.0, 3.0)
	audio_tween.start()

func _process(delta):
	parallax.scroll_offset.x -= 5 * delta
	
	plane.global_position.x += plane_dir * delta
	if plane.global_position.x > 375 or plane.global_position.x < -25:
		plane_dir *= -1
		plane.flip_h = not plane.flip_h
		bomb.flip_h = plane.flip_h
		plane.z_index *= -1
		plane.global_position.y = rng.randi_range(30, 90)
		
	
	if Input.is_action_just_pressed("drop_bomb"):
		audio_tween.interpolate_property(title_music, "volume_db", -10.0, -80.0, 3.0)
		fade_to_black_tween.interpolate_property(fade_to_black, "color:a", 0, 1.0, 2.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		fade_to_black_tween.start()
		audio_tween.start()
		await audio_tween.finished
		get_tree().change_scene_to_file("res://game.tscn")
