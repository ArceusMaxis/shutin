extends Button

@onready var child = get_child(0)

func _ready():
	pressed.connect(child.play)
