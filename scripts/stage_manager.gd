extends CanvasLayer

const STAGE_GAME = "res://stages/game_stage.tscn"

signal stage_changed

func _ready():
	
	pass

func change_stage():
	emit_signal("stage_changed")
	pass