extends Control
class_name UIItem

var item : Item
var isHeld = false
var positionDelta = Vector2()

var parentInvGrid setget setParentInvGrid
var previousInvGrid

var _icon
var _centerIcon

func updateItemInfo():
	hint_tooltip = item.itemName
	var itemInfo = ItemDb.getItemInfo(item.itemName)
	setIcon(load(itemInfo.icon))
	if itemInfo.stackSize > 1:
		$StackLabel.text = str(item.quantity)
	else:
		$StackLabel.text = ""
	if item.durability != -1:
		$DurabilityLabel.text = str(item.durability) + "/" + str(itemInfo.baseDurability)
	else:
		$DurabilityLabel.text = ""

func setParentInvGrid(p):
	previousInvGrid = parentInvGrid
	parentInvGrid = p

func initialize(initItem : Item, parentGrid):
	_icon = $CenterContainer/Icon
	_centerIcon = $CenterContainer
	
	parentInvGrid = parentGrid
	item = initItem
	setSize(item.size)
	updateItemInfo()

func setIcon(iconTex):
	_icon.texture = iconTex
	_icon.rect_min_size = Vector2(1,1) * float(InventoryUi.cellSize)
	_centerIcon.rect_rotation = 90 * int(item.rotated)

func setSize(newSize):
	rect_size = InventoryUi.cellSize * newSize
	_centerIcon.rect_pivot_offset = rect_size / 2

func rotate():
	item.rotate()
	setSize(item.size)
	_centerIcon.rect_rotation = 90 * int(item.rotated)
	#print(_icon.rect_rotation)

func _ready():
	set_process(false)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			startDrag(event.position)
			#print("grab")

func _input(event):
	if isHeld:
		if event is InputEventMouseButton:
			if event.button_index == 1 and !event.pressed:
				stopDrag()
				#print("release")
		if event is InputEventKey:
			if event.scancode == 82 and event.pressed:
				rotate()

func startDrag(position):
	positionDelta = get_global_mouse_position() - rect_global_position
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	parentInvGrid.removeItem(self)
	InventoryUi.grabItem(self)
	isHeld = true

func stopDrag():
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_STOP
	InventoryUi.dropItem(self)
	isHeld = false

func setColor(color : int):
	match color:
		0:
			self_modulate = Color("696969")
		1:
			self_modulate = Color.darkgreen
		2:
			self_modulate = Color.darkred
