extends Node
class_name Inventory

var invTitle = ""
var gridX : int = 10
var gridY : int = 10
var grid = []
var items = {}
var itemCounter = 0
var expandable = false

signal inventoryExpanded

func expandInventory(size : Vector2):
	#print("EXPANDING INVENTORY")
	gridX += size.x
	gridY += size.y
	grid.resize(gridX * gridY)
	grid.fill(null)
	rebuildGrid()
	
	
	emit_signal("inventoryExpanded")

func rebuildGrid():
	for k in items.keys():
		var pos = items[k].position
		var size = items[k].size
		
		#print("Pos: " + str(pos) + " Size: " + str(size))
		
		var ids = sizeToIDs(pos, size)
		#print("SIZEEEEEEEE :" + str(ids.size()))
		for i in ids:
			grid[i] = k
		

func _init(title = "", size : Vector2 = Vector2(5,5), items : Array = [], expand = false):
	gridX = size.x
	gridY = size.y
	grid.resize(size.x * size.y)
	grid.fill(null)
	expandable = expand
	invTitle = title
	#print("Creating inventory of size " + str(size))
	
	if items.size() > 0:
		for item in items:
			assert(addItem(item), "Floor full!")

func addItemAtPosition(item : Item,position : Vector2) -> bool:
	if !testFit(position, item.size):
		if expandable:
			addItem(item)
			return true
		else:
			return false
	var positions = sizeToIDs(position, item.size)
	#print(positions)
	
	var itemID = itemCounter
	itemCounter += 1
	
	item.position = position
	items[itemID] = item
	
	for i in positions:
		grid[i] = itemID
	
	print("Added: " + str(itemID))
	#print("Grid: " + str(grid))
	
	return true

func addItem(item : Item):
	var size = item.size
	var foundPlace = false
	var place = -1
	
	for i in range((gridX * gridY)-1):
		if grid[i] == null:
			foundPlace = testFit(IDToPos(i), size)
			if foundPlace:
				place = i
				break
	#print("adding to anywhere")
	if !foundPlace:
		#print("didn't find place, expandable: " + str(expandable))
		if expandable:
			#print("SHOULD EXPAND")
			expandInventory(item.size)
			addItem(item)
			return true
		else:
			return false
	else:
		print("Found pos: " + str(IDToPos(place)))
		return addItemAtPosition(item, IDToPos(place))

func testFit(pos : Vector2, size : Vector2) -> bool:
	var positions = sizeToIDs(pos, size);
	
	if pos.x + size.x > gridX or pos.y + size.y > gridY or pos.x < 0 or pos.y < 0:
		return false
	
	for i in positions:
		if  grid[i] != null:
			return false
	
	return true

func posToID(pos : Vector2) -> int:
	#print("posToID pos is " + str(pos))
	return int(gridX * pos.y + pos.x)

func IDToPos(id : int) -> Vector2:
	return Vector2(int(id % gridX), int(id / gridX))

func sizeToIDs(pos : Vector2, size : Vector2) -> PoolIntArray:
	var ret : PoolIntArray
	var initialID = posToID(pos)
	#print("initialID: " + str(initialID))
	for i in range(size.x * size.y):
		var id : int = initialID + (int(i / size.x) * gridX + (i % int(size.x)))
		ret.append(id)
	
	return ret

func removeItem(item):
	var id = findItemID(item)
	
	if id == -1:
		push_error("could not find item")
		return false
	
	items.erase(id)
	
	for i in range(grid.size()):
		if grid[i] == id:
			grid[i] = null
	
	print("Removed " + str(id))
	#print("Grid: " + str(grid))###############################
	
	return true

func findItemID(item):
	for i in items.keys():
		if items[i] == item:
			return i
	return -1

func removeItemAtPosition(pos):
	var id = getItemIDAtPos(pos)
	var item = items[id]
	
	return removeItem(item)

func getItemIDAtPos(pos):
	grid[posToID(pos)]

func getItems() -> Array:
	var ret = []
	for k in items.keys():
		ret.append(items[k])
	return ret
