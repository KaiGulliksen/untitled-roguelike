class_name MainMenu
extends Control

signal game_requested(load)

@onready var first_button: Button = $"%NewButton"
@onready var load_button: Button = $"%LoadButton"
