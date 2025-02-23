extends Node2D

var computer_interact : bool = false
var bed_interact : bool = false
var drums_interact : bool = false
var balcony_interact : bool = false
var total_time : float = 0.0
var current_datetime: Dictionary = {
	"year": 2020,
	"month": 6,
	"day": 12,
	"hour": 10,
	"minute": 0
}

var end_datetime: Dictionary = {
	"year": 2020,
	"month": 6,
	"day": 26,
	"hour": 20,
	"minute": 0
}

const TIME_INCREMENTS = {
	"computer": 240, 
	"sleep": 480,
	"drums": 240,     # 30 minutes
	"balcony": 60    # 15 minutes
}

@export var unders : Array[CompressedTexture2D]
@export var overs : Array[CompressedTexture2D]
@export var epilogue_scn : PackedScene

@onready var close: Button = $Close

func _on_computer_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.show_label()
		computer_interact = true

func _on_computer_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hide_label()
		computer_interact = false

func _on_bed_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.show_label()
		bed_interact = true

func _on_bed_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hide_label()
		bed_interact = false

func _ready() -> void:
	$BGM.play()
	close.pressed.connect(get_tree().quit)
	$CutScenePlayer.animation_finished.connect(visibchange)
	$DrumsC/Closebutton.pressed.connect(close_drums)
	update_time_display()

func close_drums():
	$BGM.stream_paused = false
	$Remi.can_move = true
	$DrumsC.visible = false

func visibchange():
	$Bed/gooda.stop()
	$Bed/bada.stop()
	$Balcony/bala.stop()
	$Computer/compa.stop()
	$Computer/compa2.stop()
	$BGM.stream_paused = false
	$Remi.can_move = true
	$CutScenePlayer.visible = false

func advance_time(minutes: int) -> void:
	var unix_time = Time.get_unix_time_from_datetime_dict(current_datetime)
	unix_time += minutes * 60
	current_datetime = Time.get_datetime_dict_from_unix_time(unix_time)
	update_time_display()
	art_sync()
	check_game_end()

func update_time_display() -> void:
	var time_text = "%02d/%02d/%d %02d:%02d" % [
		current_datetime.day,
		current_datetime.month,
		current_datetime.year,
		current_datetime.hour,
		current_datetime.minute
	]
	$TimeLabel.text = time_text

func check_game_end() -> void:
	var current_unix = Time.get_unix_time_from_datetime_dict(current_datetime)
	var end_unix = Time.get_unix_time_from_datetime_dict(end_datetime)
	
	if current_unix >= end_unix:
		get_tree().change_scene_to_packed(epilogue_scn)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if computer_interact:
			$BGM.stream_paused = true
			$Remi.can_move = false
			$CutScenePlayer.visible = true
			var string = "ComputerAnim" + str(randi_range(1,2))
			$CutScenePlayer.play(string)
			advance_time(TIME_INCREMENTS.computer)
			
		if bed_interact:
			$BGM.stream_paused = true
			$Remi.can_move = false
			$CutScenePlayer.visible = true
			var num = randi_range(1,1)
			var string = "SleepAnim" + str(num)
			$CutScenePlayer.play(string)
			if num == 1:
				$Bed/gooda.play()
			else:
				$Bed/bada.play()
			advance_time(TIME_INCREMENTS.sleep)
			
		if balcony_interact:
			$BGM.stream_paused = true
			$Remi.can_move = false
			$CutScenePlayer.visible = true
			var string = "BalconyAnim" + str(randi_range(1,2))
			$CutScenePlayer.play(string)
			advance_time(TIME_INCREMENTS.balcony)
			
		if drums_interact:
			$BGM.stream_paused = true
			$Remi.can_move = false
			$DrumsC.visible = true
			advance_time(TIME_INCREMENTS.drums)

func _on_balcony_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.show_label()
		balcony_interact = true

func _on_balcony_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hide_label()
		balcony_interact = false

func _on_drums_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.show_label()
		drums_interact = true

func _on_drums_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hide_label()
		drums_interact = false

func art_sync():
	if current_datetime.hour > 6 and current_datetime.hour < 18:
		$Temp.texture = unders[0]
		$TempOver.texture = overs[0]
		#PC over texture for day (didnt set up yet)
	else:
		$Temp.texture = unders[1]
		$TempOver.texture = overs[1]
		#PC over texture for night (didnt set up yet)

##TODO : change how comp anims work, new compsceneplayer + audio streams, etc
