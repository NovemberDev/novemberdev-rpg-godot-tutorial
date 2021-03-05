extends AnimatedSprite

func _ready():
	frame = 0
	connect("animation_finished", self, "on_animation_finished")

func on_animation_finished():
	queue_free()
