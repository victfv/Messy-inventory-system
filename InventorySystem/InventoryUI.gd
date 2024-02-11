extends Control


const windowWidget = preload("res://InventorySystem/Widgets/FloatingWindow.tscn")
const inventoryGrid = preload("res://InventorySystem/Widgets/Grid/InventoryGrid.tscn")
const minimizedWindowScene = preload("res://InventorySystem/Widgets/WindowBottomBar.tscn")

const FLOOR_DEFAULT_SIZE = Vector2(10,14)

var cellSize = 40

var floorInventory
var floorInventoryGrid

var dragWidget = null

onready var minWindowsHolder = $MinimizedWindows
onready var windowsHolder = $Windows

signal windowTopChanged(window)

func createInventoryWindow(inventory : Inventory):
	var window = windowWidget.instance()
	var grid = inventoryGrid.instance()
	window.connect("dragStart", self, "onWindowDragStart")
	window.connect("dragEnd", self, "onWindowDragEnd")
	window.setTitle(inventory.invTitle)
	print("Create window inv of" + str(Vector2(inventory.gridX, inventory.gridY)))
	
	$Windows.add_child(window)
	grid.setWindow(window)
	grid.setInventory(inventory)
	window.addContent(grid)
	
	var mwindow = minimizedWindowScene.instance()
	mwindow.window = window
	
	minWindowsHolder.add_child(mwindow)
	
	
	return window

func onWindowDragStart(window):
	bringWindowToTop(window)

func onWindowDragEnd(window):
	pass

func isWindowOnTop(window) -> bool:
	return (window.get_index() == windowsHolder.get_child_count() - 1)

func bringWindowToTop(window):
	$Windows.move_child(window,$Windows.get_child_count() - 1)
	emit_signal("windowTopChanged", getTopWindow())

func sendWindowToBottom(window):
	$Windows.move_child(window,0)
	emit_signal("windowTopChanged", getTopWindow())

func getTopWindow():
	return $Windows.get_child($Windows.get_child_count() - 1)

func throwOnFloor(itemWidget):
	return floorInventoryGrid.addItem(itemWidget)

func dropItem(itemWidget):
	set_process(false)
	if itemWidget is UIItem:
		var grid = getTopGrid(itemWidget.rect_global_position)
		
		if grid == null:
			assert(throwOnFloor(itemWidget), "Couldn't expand floor")
			dragWidget.setColor(0)
			dragWidget = null
			return
		print("Found grid")
		if grid.addItemAtPosition(itemWidget, itemWidget.rect_global_position):
			itemWidget.setColor(0)
			dragWidget = null
			print("Added to grid")
			return
		else:
			if !itemWidget.previousInvGrid.addItemAtGridPosition(itemWidget, itemWidget.item.position):
				print("Couldn't add to previous grid")
				if !itemWidget.previousInvGrid.addItem(itemWidget):
					print("Throwing on floor")
					assert(throwOnFloor(itemWidget), "Couldn't expand floor")
			itemWidget.setColor(0)
			dragWidget = null
			return

func getTopGrid(pos):
	var intersectingWindows = []
	for win in $Windows.get_children():
		if win.has_point(pos):
			intersectingWindows.append(win)
	
	if intersectingWindows.size() == 0:
		return null
	
	var topPos = -1
	var topWindow = null
	
	for win in intersectingWindows:
		if topPos < win.get_position_in_parent():
			topWindow = win
			topPos = win.get_position_in_parent()
	
	assert(topWindow != null, "Top window is null!")
	
	return topWindow.getContent()

func grabItem(itemWidget):
	var prevPos = itemWidget.rect_global_position
	itemWidget.parentInvGrid = null
	itemWidget.get_parent().remove_child(itemWidget)
	$Dragging.add_child(itemWidget)
	itemWidget.rect_global_position = prevPos
	dragWidget = itemWidget
	set_process(true)

func _ready():
	set_process(false)
	var inv = Inventory.new("Floor", FLOOR_DEFAULT_SIZE, [], true)
	var window = createInventoryWindow(inv)
	floorInventoryGrid = window.getContent()
	floorInventory = inv
	
	var newInv = Inventory.new("Backpack", Vector2(6,8))
	for i in range(21):
		newInv.addItem(Item.new("Cheese"))
	createInventoryWindow(newInv)
	
	var pocketInv = Inventory.new("Pockets", Vector2(6,1))
	createInventoryWindow(pocketInv)
	
	emit_signal("windowTopChanged", getTopWindow())

func _process(delta):
	if dragWidget != null:
		var pos = get_global_mouse_position() - dragWidget.positionDelta
		var tGrid : InventoryGrid = getTopGrid(pos)
		if tGrid != null:
			if tGrid.testFit(pos, dragWidget.item):
				dragWidget.setColor(1)
				var nPos = tGrid.postToGridPos(pos)
				dragWidget.rect_global_position = lerp(dragWidget.rect_global_position, nPos, delta * 40)
			else:
				dragWidget.rect_global_position = get_global_mouse_position() - dragWidget.positionDelta
				dragWidget.setColor(2)
		else:
			dragWidget.rect_global_position = get_global_mouse_position() - dragWidget.positionDelta
			dragWidget.setColor(2)
