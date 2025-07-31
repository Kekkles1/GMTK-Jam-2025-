extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D  

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALL_SPEED = 0
const WALL_JUMP_FORCE = Vector2(250, -400)

var wall_dir := 0  # -1 = left wall, 1 = right wall, 0 = none

func _ready() -> void:
	#Activates the camera so it follows player
	cam.make_current()

func _physics_process(delta: float) -> void:
	# can replace this with is_on_floor_only() if we don't wanna detect slopes im not sure rn
	var on_floor=is_on_floor()
	var on_wall=is_on_wall()
	
	#detect what a wall is
	if on_wall and not on_floor:
		var wall_normal=get_wall_normal()
		wall_dir=int(wall_normal.x)
	else:
		wall_dir=0

	if not is_on_floor():
		velocity+= get_gravity() * delta

#wall hang
	if wall_dir!=0:
		velocity.y=WALL_SPEED
		
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif wall_dir != 0:
		#Wall jump: opposite direction of wall
			velocity.x = WALL_JUMP_FORCE.x * -wall_dir
			velocity.y = WALL_JUMP_FORCE.y
			sprite.play("wall-jump")

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation
	if not is_on_floor():
		sprite.play("jump")
	elif velocity.x == 0:
		sprite.play("default") 
	else:
		sprite.play("run")
		sprite.flip_h = velocity.x < 0
