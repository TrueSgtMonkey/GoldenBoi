extends Control

export (String) var stuffName = "Gold: "

var goldCountRef : Label = null

func _ready():
	goldCountRef = $CenterContainer2/GoldCount

func updateGoldDisp(gold : int):
	goldCountRef.text = stuffName + str(gold)
