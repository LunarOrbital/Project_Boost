extends CanvasLayer
@onready var label: Label = $MarginContainer/FoldableContainer/Label

func updateFuel(num):
	label.text = "Fuel: " + str(int(num)) + "%"
