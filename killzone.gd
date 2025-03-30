extends Area3D


func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is Knight:  # Controleer of de speler de zone raakt
		body.respawn()
	# Replace with function body.
