extends CharacterBody2D

var speed = 130
@export var can_move = true

func _physics_process(delta):
	if can_move:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * speed
		move_and_slide()

func show_label():
	$Label.visible = true
	
func hide_label():
	$Label.visible = false
