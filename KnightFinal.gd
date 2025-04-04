extends CharacterBody3D

class_name Knight

@export var Dev_speed = 50.0
@export var speed = 5.0
@export var acceleration = 2
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.0055
@export var rotation_speed = 12.0

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig
@onready var anim_tree = $AnimationTree
@onready var anim_state = $AnimationTree.get("parameters/playback")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var last_floor = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	velocity.y += -gravity * delta
	get_move_input(delta)
	
	move_and_slide()
	
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
		
	if is_on_floor() and Input.is_action_just_pressed("space"):
		velocity.y = jump_speed
		jumping = true
		anim_tree.set("parameters/conditions/grounded", false)
		anim_tree.set("parameters/conditions/jumping", jumping)
	
		# We just hit the floor after being in the air
	if is_on_floor() and not last_floor:
		jumping = false  # Reset jumping state
		anim_tree.set("parameters/conditions/grounded", true)
		anim_tree.set("parameters/conditions/jumping", false)  # Ensure jumping is reset
	
	
	# We're in the air, but we didn't jump
	if not is_on_floor() and not jumping:
		anim_state.travel("Jump_Idle")
		anim_tree.set("parameters/conditions/grounded", false)
	last_floor = is_on_floor()
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if is_on_floor() and Input.is_action_just_pressed("Dev_jump"):
		velocity.y = Dev_speed
		jumping = true
		anim_tree.set("parameters/conditions/grounded", false)
		anim_tree.set("parameters/conditions/jumping", jumping)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	var vl = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)
	velocity.y = vy
var respawn_position = Vector3(0, 2, 0)  # Pas deze aan naar de gewenste spawnlocatie

func respawn():
	global_transform.origin = respawn_position
	velocity = Vector3.ZERO  # Reset snelheid om onverwachte bewegingen te voorkomen
	
