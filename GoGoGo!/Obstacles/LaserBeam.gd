extends Node2D

var direction : Globals.directions

func set_timer(wait_time : float):
	$Timer.wait_time = wait_time
	$Timer.start()

func rotate_beam():
	match direction:
		Globals.directions.LEFT:
			self.rotation_degrees = 90
		Globals.directions.UP:
			self.rotation_degrees = 180
		Globals.directions.RIGHT:
			self.rotation_degrees = 270
		# directions.DOWN: Already facing down, so don't rotate.


func disappear() -> void:
	self.visible = false
	self.queue_free()
