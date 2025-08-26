@tool
class_name Controllable extends Component

static var Locks: LockList = LockList.new()

@export var control_scheme: ControlScheme

var _viewport_ref: Viewport

func _get_configuration_requirements() -> Array[Variant]: return [Selectable, Nav3DMotor]

func _ready() -> void:
	_viewport_ref = EditorInterface.get_editor_viewport_3d() if Engine.is_editor_hint() else get_viewport()

func _enter_tree() -> void:
	if control_scheme: control_scheme.setup(E())

func _exit_tree() -> void:
	if control_scheme: control_scheme.teardown(E())

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Locks.is_locked: return
	if C(Selectable).selected:
		control_scheme.on_input(event, E())

func _process(_delta: float) -> void:
	if C(Selectable).selected:
		var position := _viewport_ref.get_camera_3d().unproject_position(E().global_position + Vector3.UP * Perception.AGENT_HEIGHT)
		var scaling: Vector2 = Vector2(get_window().content_scale_size) / Vector2(get_viewport().size);
		var mod := scaling.x if get_window().size.x / get_window().size.y < 16/9 else scaling.y
		RenderingServer.global_shader_parameter_set("keyhole_screen_position", position)
		RenderingServer.global_shader_parameter_set("keyhole_world_position", E().global_position)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Locks.is_locked: return
	if C(Selectable).selected:
		control_scheme.on_physics_process(delta, E())
