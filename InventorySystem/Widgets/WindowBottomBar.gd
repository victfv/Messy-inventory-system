extends Button

var window : FloatingWindow = null

const openTheme = preload("res://InventorySystem/Widgets/BottomBarOpenTheme.tres")
const closedTheme = preload("res://InventorySystem/Widgets/BottomBarCloseTheme.tres")

signal windowToTop(window)

func _ready():
	window.connect("minimize", self, "onWindowMinimize")
	window.connect("maximize", self, "onWindowMaximize")
	
	text = window.getTitle()

func _on_MinimizedWindow_pressed():
	if window.getMinimized():
		window.maximize()
	else:
		if InventoryUi.isWindowOnTop(window):
			window.minimize()
		else:
			window.goToTop()

func onWindowMinimize(wd):
	theme = closedTheme

func onWindowMaximize(wd):
	theme = openTheme
