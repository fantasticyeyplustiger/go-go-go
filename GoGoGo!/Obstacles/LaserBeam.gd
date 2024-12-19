extends Node2D

func rotate_beam(direction : Globals.directions):
	match direction:
		Globals.directions.LEFT:
			self.rotation_degrees = 90
		Globals.directions.UP:
			self.rotation_degrees = 180
		Globals.directions.RIGHT:
			self.rotation_degrees = 270
		# directions.DOWN: Already facing down, so don't rotate.
