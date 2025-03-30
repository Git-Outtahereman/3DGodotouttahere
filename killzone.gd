extends Area3D


func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D :  # Check if it's the player
		body.respawn()  # Call respawn on the player



	
