@tool
class_name Nav3DMotor extends Component

const UNIT_ACCELERATION = 0.2
const ENTITY_LOOKAT_SPEED = 16
const UNIT_DECELERATION_DIST = 1.5
const UNIT_MAX_DECELERATION = 0.8
const UNIT_STEERING_STRENGTH = 2.0

signal movement_start
signal movement_stop

var _lookat_target: Vector3
var _target_position: Vector3
var _current_velocity: Vector3
var _target_velocity: Vector3

var _character: CharacterBody3D:
	get(): return C(Body3DCharacter).get_collision_object() as CharacterBody3D
var _navigation_agent: NavigationAgent3D:
	get(): return C(Body3DCharacter).get_navigation_agent() as NavigationAgent3D

func move_to(global_position: Vector3) -> void:
	_navigation_agent.target_position = global_position
	movement_start.emit()

func _get_configuration_requirements() -> Array[Variant]: return [Body3DCharacter, Stats]

func _ready() -> void:
	_navigation_agent.velocity_computed.connect(_on_velocity_computed)
	_stop()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if not _character or not _navigation_agent: return

	if not _navigation_agent.is_navigation_finished():
		_steer()
	else:
		_stop()

	_gaze(delta)

func _steer() -> void:
	var next := _navigation_agent.get_next_path_position()
	_agent_steer((next - _character.global_position).normalized() * C(Stats)[STATS.MOVE_SPEED])

func _agent_steer(v: Vector3) -> void:
	_set_velocity(v)
	_update_velocity()

	if _navigation_agent.avoidance_enabled:
		_navigation_agent.set_velocity(_current_velocity)
	else:
		_on_velocity_computed(_current_velocity)

func _set_velocity(_velocity: Vector3) -> void:
	var decelerate := _navigation_agent.distance_to_target() < UNIT_DECELERATION_DIST
	_target_velocity = _velocity if not decelerate else _velocity * max((_navigation_agent.distance_to_target() - _navigation_agent.target_desired_distance) / UNIT_DECELERATION_DIST, 1-UNIT_MAX_DECELERATION)

func _update_velocity() -> void:
	if not _current_velocity.is_equal_approx(_target_velocity):
		var dir := (_navigation_agent.target_position - E().global_position).normalized()
		var acceleration := UNIT_ACCELERATION + (1 - _current_velocity.normalized().dot(dir)) * UNIT_STEERING_STRENGTH
		acceleration = min(acceleration, UNIT_ACCELERATION * 2)
		_current_velocity = _current_velocity.slerp(_target_velocity, acceleration)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if Engine.is_editor_hint(): return

	if safe_velocity.length() == 0:
		return

	_current_velocity = safe_velocity

	var look_dir: Vector3 = _character.global_position + C(Body).get_collision_object().get_velocity()
	if !look_dir.is_equal_approx(_character.global_position):
		_lookat_target = look_dir

	_execute_move(safe_velocity)

func _execute_move(_velocity: Vector3) -> void:
	_character.velocity = _velocity # Internal velocity unrelated to member variable
	_character.move_and_slide()

func _gaze(_delta: float) -> void:
	# Same check as in source to avoid error coming from colinear vectors.
	# See: https://github.com/godotengine/godot/blob/967e2d499acd7d03a3e69002d373880e43fe0e45/core/math/basis.cpp#L1032
	var v_z := (_lookat_target - _character.global_transform.origin).normalized();
	var v_x := Vector3.UP.cross(v_z);
	if v_x.is_zero_approx(): return

	var looking_at := _character.global_transform.looking_at(_lookat_target, Vector3.UP, true)
	_character.global_rotation.y = lerp_angle(_character.global_rotation.y, looking_at.basis.get_euler().y, _delta * ENTITY_LOOKAT_SPEED)

func _stop() -> void:
	if _target_position == _character.global_position:
		return # Already stopped

	_target_position = _character.global_position

	_set_velocity(Vector3.ZERO)
	_update_velocity()
	movement_stop.emit()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()
	if !C(Stats).get(STATS.MOVE_SPEED):
		warnings.append("Parent [Stats] component missing required ["+STATS.MOVE_SPEED+"] stat.")
	return warnings
