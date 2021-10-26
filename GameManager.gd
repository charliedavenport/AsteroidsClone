extends Node
class_name GameManager

const player_scene = preload("res://Player/Player.tscn")

var player: Player
onready var gui = get_node("CanvasLayer/GUI")
onready var asteroid_spawner = get_node("AsteroidSpawner")

# PLAYER VARS
export var max_lives: int = 5
var player_lives: int
var game_over: bool

# SCORING
export var big_asteroid_pts: int = 20
export var medium_asteroid_pts: int = 50
export var small_asteroid_pts: int = 100
export var big_saucer_pts: int = 200
export var small_saucer_pts: int = 1000
var score: int

export var beg_asteroids_per_wave: int = 4
var wave: int
var asteroids_per_wave: int

export var game_over_timer: float = 1.5
var is_start_screen: bool
var is_game_over_screen: bool
var is_game_over_timer: bool

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	asteroid_spawner.connect("no_asteroids_left", self, "on_no_asteroids_left")
	is_game_over_timer = false
	is_game_over_screen = false
	start_screen()

func start_screen() -> void:
	is_start_screen = true
	asteroid_spawner.spawn_asteroid_wave(3)
	gui.start_screen()

func game_over() -> void:
	is_game_over_screen = true
	gui.game_over_screen()
	#game_over_timer.start()
	is_game_over_timer = true
	yield(get_tree().create_timer(game_over_timer), "timeout")
	is_game_over_timer = false
	gui.show_press_any_btn()

func _input(event):
	if (is_start_screen or is_game_over_screen) and event is InputEventKey and event.pressed and not is_game_over_timer:
		is_start_screen = false
		is_game_over_screen = false
		reset_game()

func reset_game() -> void:
	game_over = false
	player_lives = max_lives
	score = 0
	wave = 1
	asteroids_per_wave = beg_asteroids_per_wave
	asteroid_spawner.clear_asteroids()
	gui.call_deferred("start_game", max_lives, score, wave)
	player = player_scene.instance()
	get_tree().root.call_deferred("add_child", player)
	player.connect("player_hit", self, "on_player_hit")
	asteroid_spawner.spawn_asteroid_wave(asteroids_per_wave)

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")

func on_projectile_hit(node) -> void:
	if node is Asteroid:
		if node is Asteroid_Big:
			score += big_asteroid_pts
			gui.set_score(score)
		elif node is Asteroid_Small:
			score += small_asteroid_pts
			gui.set_score(score)
		node.destroy()

func on_player_hit() -> void:
	player_lives -= 1
	game_over = (player_lives == 0)
	player.kill(game_over)
	gui.decrement_lives()
	if game_over:
		game_over()

func on_no_asteroids_left() -> void:
	wave += 1
	gui.set_wave(wave)
	asteroids_per_wave += 1
	asteroid_spawner.spawn_asteroid_wave(asteroids_per_wave)
