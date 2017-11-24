# script bird.gd
extends RigidBody2D

onready var state = FlyingState.new(self)

var speed = 50

const STATE_FLYING = 0
const STATE_FLAPPING = 1
const STATE_HIT = 2
const STATE_GROUNDED = 3

signal state_changed

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	add_to_group(game.GROUP_BIRDS)
	connect("body_enter", self, "_on_body_enter")
	pass

func _fixed_process(delta):
	state.update(delta)
	pass

func _input(event):
	state.input(event)
	pass

func _on_body_enter(other_body):
	if state.has_method("on_body_enter"):
		state.on_body_enter(other_body)
	pass

func set_state(new_state):
	state.exit()
	
	if new_state == STATE_FLYING:
		state = FlyingState.new(self)
	elif new_state == STATE_FLAPPING:
		state = FlappingState.new(self)
	elif new_state == STATE_HIT:
		state = HitState.new(self)
	elif new_state == STATE_GROUNDED:
		state = GroundedState.new(self)
	pass
	
	emit_signal("state_changed",self)
func get_state():
	if state extends FlyingState:
		return STATE_FLYING
	elif state extends FlappingState:
		return STATE_FLAPPING
	elif state extends HitState:
		return STATE_HIT
	elif state extends GroundedState:
		return STATE_GROUNDED
	
class FlyingState:
	var bird
	var prev_gravity_scale
	
	func _init(bird):
		self.bird = bird
		bird.get_node("anim").play("flying")
		bird.set_linear_velocity(Vector2(bird.speed, bird.get_linear_velocity().y))
		
		prev_gravity_scale = bird.get_gravity_scale()
		bird.set_gravity_scale(0)
		pass
	
	func update(delta):
		pass
	
	func input(event):
		pass
	
	func exit():
		bird.set_gravity_scale(prev_gravity_scale)
		bird.get_node("anim").stop()
		bird.get_node("anim_sprite").set_pos(Vector2(0,0))
		pass
	
class FlappingState:
	var bird
	
	func _init(bird):
		self.bird = bird
		
		bird.set_linear_velocity(Vector2(bird.speed, bird.get_linear_velocity().y))
		flap()
		pass
	
	func update(delta):
		if rad2deg(bird.get_rot()) > 30:
			bird.set_rot(deg2rad(30))
			bird.set_angular_velocity(0)
		
		if bird.get_linear_velocity().y > 0:
			bird.set_angular_velocity(1.5)
		pass
	
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_PIPES):
			bird.set_state(bird.STATE_HIT)
		elif other_body.is_in_group(game.GROUP_GROUNDS):
			bird.set_state(bird.STATE_GROUNDED)
		pass
	
	func input(event):
		if event.is_action_pressed("flap"): 
			flap()
		pass
	
	func exit():
		pass
	
	func flap():
		bird.set_linear_velocity(Vector2(bird.get_linear_velocity().x, -150))
		bird.set_angular_velocity(-3)
		bird.get_node("anim").play("flap")
		pass
	
class HitState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.set_linear_velocity(Vector2(0,0))
		bird.set_angular_velocity(2)
		
		var other_body = bird.get_colliding_bodies()[0]
		bird.add_collision_exception_with(other_body)
		pass
	
	func update(delta):
		pass
	
	func input(event):
		pass
	
	func on_body_enter(other_body):
		if other_body.is_in_group(game.GROUP_GROUNDS):
			bird.set_state(bird.STATE_GROUNDED)
	
	func exit():
		pass

class GroundedState:
	var bird
	
	func _init(bird):
		self.bird = bird
		bird.set_linear_velocity(Vector2(0,0))
		bird.set_angular_velocity(0)
		print(bird.get_linear_velocity())
		pass
	
	func update(delta):
		pass
	
	func input(event):
		pass
	
	func exit():
		pass