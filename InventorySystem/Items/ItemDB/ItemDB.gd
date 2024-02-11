extends Node

#type: consumable, weapon, equipment
#equipmentType: armor, helmet, special

#general priprieties
#{"sizex" : 2, "sizey" : 2, "icon" : "res://icon.png", "value" = 2, "weight" = 0.1, "stackSize" : 1, "baseDurability" : -1, "type" : "consumable"}

#consumable proprieties:
#foodS, waterS, healthS, duration, effect

#equipment proprieties:
#defense, offence, effect, active

const itemDB = {
	"Cheese" : {"sizex" : 2, "sizey" : 1, "icon" : "res://icon.png", "value" : 5, "weight" : 0.15, "stackSize" : 1, "baseDurability" : 4,"type" : "consumable", "food" : 12},
	"Crackers" : {"sizex" : 1, "sizey" : 2, "icon" : "res://icon.png", "value" : 8, "weight" : 0.6, "stackSize" : 1, "baseDurability" : 12,"type" : "consumable", "food" : 5}
}

func getItemInfo(itemName : String):
	if itemDB.has(itemName):
		return itemDB[itemName]
	else:
		return null
