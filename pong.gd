extends Node2D


# constants
const INITIAL_BALL_SPEED = 140
const PAD_SPEED = 150

# nodes
var ball
var left_pad
var right_pad
var right_score
var left_score

# vars
var screen_size
var pad_size
var ball_pos
var direction = Vector2(1.0, 0.0)
var ball_speed = INITIAL_BALL_SPEED


func _ready():
	ball = get_node('ball')
	left_pad = get_node('left_pad')
	right_pad = get_node('right_pad')
	right_score = get_node('right_score')
	left_score = get_node('left_score')

	screen_size = get_viewport_rect().size
	pad_size = left_pad.get_texture().get_size()
	ball_pos = ball.get_pos()

	set_process(true)


func _process(delta):
	# start ball movement
	ball_pos += direction * ball_speed * delta

	handle_roof_floor_collision()
	handle_pads_collision()
	is_game_over()
	move_pad(left_pad, delta, 'left_move_up', 'left_move_down')
	move_pad(right_pad, delta, 'right_move_up', 'right_move_down')


func handle_roof_floor_collision():
	if ((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0)):
		direction.y = direction.y * -1


func handle_pads_collision():
	var left_rect = Rect2(left_pad.get_pos() - pad_size * 0.5, pad_size)
	var right_rect = Rect2(right_pad.get_pos() - pad_size * 0.5, pad_size)

	if ((left_rect.has_point(ball_pos) and direction.x < 0) or
		(right_rect.has_point(ball_pos) and direction.x > 0)):
		direction.x = direction.x * -1
		direction.y = randf() * 2.0 - 1
		direction = direction.normalized()
		ball_speed *= 1.1


func move_pad(pad, delta, action_up, action_down):
	var pos = pad.get_pos()

	if (Input.is_action_pressed(action_up) and pos.y > (pad_size.y / 2)):
		pos.y += -PAD_SPEED * delta
	elif (Input.is_action_pressed(action_down) and pos.y < screen_size.y - pad_size.y / 2):
		pos.y += PAD_SPEED * delta
	
	pad.set_pos(pos)


func is_game_over():
	var over_left = ball_pos.x < 0
	var over_right = ball_pos.x > screen_size.x

	if (over_left or over_right):
		if (over_left):
			right_score.set_text(str(int(right_score.get_text()) + 1))
			direction = Vector2(1.0, 0.0)
		else:
			left_score.set_text(str(int(left_score.get_text()) + 1))
			direction = Vector2(-1.0, 0.0)

		ball_pos = screen_size * 0.5
		ball_speed = INITIAL_BALL_SPEED

	ball.set_pos(ball_pos)
