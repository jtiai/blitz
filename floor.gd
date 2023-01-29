extends AnimatedSprite2D

@onready var skyscraper = $".."
@onready var destroy_sound = $"../Destroy sound"

func _on_Area2D_area_entered(area):
	visible = false
	skyscraper.floors -= 1
	if not destroy_sound.playing:
		destroy_sound.play()
	await destroy_sound.finished
	queue_free()
