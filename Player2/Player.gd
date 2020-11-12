extends KinematicBody

var speed = 5
var velocity = Vector3()
var direction = Vector3()
var gravity = -9.8
var max_speed = 4

remote func _set_position(pos):
	global_transform.origin = pos

func _physics_process(_delta):
	var desired_velocity = get_input() * speed
	direction = get_input()
	velocity.y += gravity * _delta
	
	if direction != Vector3():
		if is_network_master():
			var _moved = move_and_slide(direction * speed, Vector3.UP)
		rpc_unreliable("_set_position", global_transform.origin)

	velocity.x += desired_velocity.x
	velocity.z += desired_velocity.z
	var current_speed = velocity.length()
	velocity = velocity.normalized() * clamp(current_speed,0,max_speed)
	$AnimationTree.set("parameters/Idle_Walk/blend_amount", current_speed/max_speed) 
	velocity = move_and_slide(velocity, Vector3.UP, true)



func get_input():
	var to_return = Vector3()
	
	if Input.is_action_pressed("left"):
		to_return -= transform.basis.x
	elif Input.is_action_pressed("right"):
		to_return += transform.basis.x
	if Input.is_action_pressed("forward"):
		to_return -= transform.basis.z
	elif Input.is_action_pressed("back"):
		to_return += transform.basis.z
	to_return = to_return.normalized()
	return to_return
