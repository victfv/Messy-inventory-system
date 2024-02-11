extends Resource
class_name Item

#export var itemName = ""
#export var stackSize = 1
#export var durability = -1
#export (itemType) var type = itemType.consumable
# var value = 125.0
#export var itemTypeRsrc : Resource

export var itemName = ""
export var position = Vector2()
export var size = Vector2(2,2)
export var rotated = false
export var quantity = 1
export var durability = -1

func _init(iName, qtty = 1):
	itemName = iName
	var itemInfo = ItemDb.getItemInfo(itemName)
	if itemInfo == null:
		return null
	size = Vector2(itemInfo.sizex, itemInfo.sizey)
	quantity = qtty
	durability = itemInfo.baseDurability

func rotate():
	size = Vector2(size.y, size.x)
	rotated = !rotated
