extends Control
class_name FloatingWindow

export var hasCloseButton = false

var dragging = false
var dragDelta = Vector2()
var content
var title = ""
var minimized = false

onready var closeButton = $ContentMargin/VBoxContainer/Panel/HBoxContainer/CloseButton

signal dragStart(window)
signal dragEnd(window)
signal minimize(window)
signal maximize(window)

func getMinimized():
	return minimized

func setSize(size : Vector2):
	print(size)
	rect_size = size + Vector2(16,48)
	rect_pivot_offset.y = rect_size.y

func setTitle(t : String):
	title = t
	$ContentMargin/VBoxContainer/Panel/CenterContainer/Title.text = title

func getTitle() -> String:
	return title

func addContent(content):
	$ContentMargin/VBoxContainer/Content.add_child(content)

func getContent():
	return $ContentMargin/VBoxContainer/Content.get_child(0)

func _ready():
	set_process(false)
	InventoryUi.connect("windowTopChanged", self, "onWindowOrderChange")
	closeButton.visible = hasCloseButton

func onWindowOrderChange(topWindow):
	if topWindow == self:
		$ContentMargin/VBoxContainer/Panel.self_modulate = Color.white
	else:
		$ContentMargin/VBoxContainer/Panel.self_modulate = Color.darkgray

func _on_Panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			startDrag()

func _input(event):
	if dragging and event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			endDrag()

func _process(delta):
	var npos = get_global_mouse_position() - dragDelta
	var vsize = get_viewport().size
	rect_position.x = clamp(npos.x, -(rect_size.x - 32), vsize.x - 32)
	rect_position.y = clamp(npos.y, 0, vsize.y - 64)

func startDrag():
	dragging = true
	dragDelta = get_global_mouse_position() - rect_position
	set_process(true)
	emit_signal("dragStart", self)

func endDrag():
	dragging = false
	set_process(false)
	emit_signal("dragEnd", self)

func has_point(point):
	return get_rect().has_point(point)

func _on_MinimizeButton_pressed():
	minimize()

func goToTop():
	InventoryUi.bringWindowToTop(self)

func maximize():
	if minimized:
		goToTop()
		visible = true
		minimized = false
		$AnimationPlayer.play_backwards("Minimize")

func minimize():
	if !minimized:
		minimized = true
		$AnimationPlayer.play("Minimize")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Minimize":
		if minimized:
			InventoryUi.sendWindowToBottom(self)
			visible = false
			emit_signal("minimize", self)
		else:
			emit_signal("maximize", self)
