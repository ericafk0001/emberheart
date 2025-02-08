extends Node

@onready var currency_ui: Control = $CanvasLayer/CurrencyUI
@onready var coin_label: Label = $CanvasLayer/CurrencyUI/Label

var coins = 0
var duck = 0

func add_coin():
	coins += 1
	coin_label.text = "Coins: " + str(coins)
 
func add_duck():
	duck += 1
	print(duck)
