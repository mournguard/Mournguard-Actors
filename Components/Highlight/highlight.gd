@tool
class_name Highlight extends Component

@export var fx: Node3D

func _get_configuration_requirements() -> Array[Variant]: return [Body]

var visible: bool = false:
	set(v):
		visible = v
		_sync_visible()

func _ready() -> void:
	_sync_visible()

func _process(_delta: float) -> void:
	# This is for when the scene is opened directly in the editor
	if !(E() is Entity): return

	if fx and (fx.visible or Engine.is_editor_hint()):
		fx.global_position = C(Body).get_collision_object().global_position

func _sync_visible() -> void:
	if fx: fx.visible = visible
