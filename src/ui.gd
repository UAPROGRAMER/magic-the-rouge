extends CanvasLayer

class_name UI

@onready var input_handler: InputHandler = $"../InputHandler"
@onready var menu: ColorRect = $Menu
@onready var uibg: ColorRect = $UIBG

func update_info(max_health: int, health: int, gold: int) -> void:
	$BottomUI/hp/hp_label.text = str(health) + "/" + str(max_health)
	$BottomUI/coins/coins_label.text = str(gold)

func _on_menu_button_pressed() -> void:
	input_handler.active = false
	uibg.visible = true
	menu.visible = true

func _on_resume_button_pressed() -> void:
	menu.visible = false
	uibg.visible = false
	input_handler.active = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()
