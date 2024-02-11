extends Control
class_name InventoryGrid

var inventory : Inventory
var expandable = false
onready var window : FloatingWindow

onready var gridContainer = $GridContainer
onready var itemsContaier = $Items

const itemWidget = preload("res://InventorySystem/Widgets/UIItem.tscn")

func setWindow(win):
	window = win

func setInventory(inv : Inventory):
	inventory = inv

func _ready():
	inventory.connect("inventoryExpanded", self, "onInventoryExpanded")
	expandable = inventory.expandable
	window.setSize(Vector2(inventory.gridX, inventory.gridY) * InventoryUi.cellSize)
	rect_min_size = Vector2(inventory.gridX, inventory.gridY) * InventoryUi.cellSize
	buildGrid()
	setUpItems()
	#if expandable:
	#	inventory.expandInventory(Vector2(2,2))

func onInventoryExpanded():
	print("Expanding grid UI")
	rebuildGrid()

func rebuildGrid():
	#print("Grid slots before " + str(gridContainter.get_child_count()))
	for c in gridContainer.get_children():
		c.free()
	
	#print("Grid slots after clear " + str(gridContainter.get_child_count()))
	
	gridContainer.columns = inventory.gridX
	var gridSlotTex = load("res://InventorySystem/Textures/UITextures/GridSquare.png")
	var gridSlotRect = TextureRect.new()
	gridSlotRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gridSlotRect.texture = gridSlotTex
	for i in range((inventory.gridX * inventory.gridY) - 1):
		gridContainer.add_child(gridSlotRect.duplicate(8))
	
	gridContainer.add_child(gridSlotRect)
	gridContainer.rect_scale = Vector2(1,1) * float(InventoryUi.cellSize) / 64.0
	$ScrollContainer/ScrollTop.rect_min_size = Vector2(inventory.gridX, inventory.gridY) * float(InventoryUi.cellSize)
	
	for i in itemsContaier.get_children():
		i.queue_free()
	
	setUpItems()
	#print("Grid slots after " + str(gridContainter.get_child_count()))
	

func buildGrid():
	if expandable:
		remove_child(gridContainer)
		remove_child(itemsContaier)
		$ScrollContainer/ScrollTop.add_child(gridContainer)
		$ScrollContainer/ScrollTop.add_child(itemsContaier)
	else:
		$ScrollContainer.queue_free()
	gridContainer.columns = inventory.gridX
	var gridSlotTex = load("res://InventorySystem/Textures/UITextures/GridSquare.png")
	var gridSlotRect = TextureRect.new()
	gridSlotRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gridSlotRect.texture = gridSlotTex
	#print("GRID " + str(inventory.gridX))
	for i in range((inventory.gridX * inventory.gridY) - 1):
		gridContainer.add_child(gridSlotRect.duplicate(8))
	
	gridContainer.add_child(gridSlotRect)
	gridContainer.rect_scale = Vector2(1,1) * float(InventoryUi.cellSize) / 64.0

func expandInventory():
	pass

func setUpItems():
	var items = inventory.getItems()
	for i in items:
		setUpItem(i)

func setUpItem(item):
	var currentItemWid = itemWidget.instance()
	currentItemWid.initialize(item, self)
	itemsContaier.add_child(currentItemWid)
	currentItemWid.rect_position = gridToPos(item.position)

func addItem(widget : UIItem):
	var item = widget.item
	if inventory.addItem(item):
		widget.get_parent().remove_child(widget)
		itemsContaier.add_child(widget)
		widget.rect_position = gridToPos(item.position)
		widget.parentInvGrid = self
		return true
	return false

func addItemAtPosition(widget : UIItem , pos : Vector2):
	var item = widget.item
	var gridPos = posToGrid(pos)
	if inventory.addItemAtPosition(item, gridPos):
		widget.get_parent().remove_child(widget)
		itemsContaier.add_child(widget)
		widget.rect_position = gridToPos(item.position)
		widget.parentInvGrid = self
		
		return true
	
	return false

func addItemAtGridPosition(widget : UIItem , gridPos : Vector2) -> bool:
	var item = widget.item
	if inventory.addItemAtPosition(item, gridPos):
		widget.get_parent().remove_child(widget)
		itemsContaier.add_child(widget)
		widget.rect_position = gridToPos(item.position)
		widget.parentInvGrid = self
		
		return true
	
	return false

func postToGridPos(pos : Vector2, global = true) -> Vector2:
	return gridToPos(posToGrid(pos), false)

func posToGrid(pos : Vector2) -> Vector2:
	var gridPos = ((pos - rect_global_position + Vector2(1,1))/InventoryUi.cellSize)
	gridPos = Vector2(floor(gridPos.x),floor(gridPos.y))
	return gridPos

func gridToPos(gridPos : Vector2, local = true) -> Vector2:
	if local:
		return gridPos * InventoryUi.cellSize
	else:
		return rect_global_position + gridPos * InventoryUi.cellSize

func removeItem(itemWidget):
	#print("removedItem")
	assert(inventory.removeItem(itemWidget.item), "Item could not be removed: NOT FOUND!")

func testFit(pos, item):
	return inventory.testFit(posToGrid(pos), item.size)
