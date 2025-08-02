extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D  

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALL_SPEED = 0
const WALL_JUMP_FORCE = Vector2(250, -400)
const JUMP_BUFFER = 0.2
const COYOTE_TIMER = 0.1
const AIR_SPIN = -200

var wall_dir := 0  # -1 = left wall, 1 = right wall, 0 = none
var jump_buffer_timer := 0.0
var coyote_timer := 0.0
var has_air_spin := false

func _ready() -> void:
	#makes camera current and follows player
	cam.make_current()


func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	var on_wall = is_on_wall()

	if on_floor:
		coyote_timer = COYOTE_TIMER
		has_air_spin = false

	# detect wall
	if on_wall and not on_floor:
		var wall_normal = get_wall_normal()
		wall_dir = int(wall_normal.x)
	else:
		wall_dir = 0

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if coyote_timer > 0:
		coyote_timer -= delta

	# applies gravity
	if not on_floor:
		velocity += get_gravity() * delta

#air spin
	if Input.is_action_pressed("move_air_spin") and not on_floor and not has_air_spin:
		velocity.y = AIR_SPIN
		has_air_spin = true
	
	if Input.is_action_just_pressed("move_jump"):
		jump_buffer_timer = JUMP_BUFFER

	if jump_buffer_timer > 0:
		if on_floor or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
		elif wall_dir != 0:
			velocity.x = WALL_JUMP_FORCE.x * -wall_dir
			velocity.y = WALL_JUMP_FORCE.y
			sprite.play("wall-jump")
			jump_buffer_timer = 0

#plays when you are falling
	if Input.is_action_just_released("move_jump") and velocity.y < 0:
		#tweak the number  maybe something else is better idk
		velocity.y=JUMP_VELOCITY / 3

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation
	if not on_floor:
		sprite.play("jump")
		sprite.flip_h = velocity. x < 0
	elif velocity.x == 0:
		sprite.play("default")
	else:
		sprite.play("run")
		sprite.flip_h = velocity.x < 0
