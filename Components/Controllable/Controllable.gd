@tool
class_name Controllable extends Component

static var Locks: LockList = LockList.new()

@export var control_scheme: ControlScheme

func _get_configuration_requirements() -> Array[Variant]: return [Selectable, Nav3DMotor]

func _enter_tree() -> void:
	if control_scheme: control_scheme.setup(E())

func _exit_tree() -> void:
	if control_scheme: control_scheme.teardown(E())

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Locks.is_locked: return
	if C(Selectable).selected:
		control_scheme.on_input(event, E())

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Locks.is_locked: return
	if C(Selectable).selected:
		control_scheme.on_physics_process(delta, E())
