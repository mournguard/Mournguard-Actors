@tool
class_name Selectable extends Component

const SELECTABLE_GROUP_NAME = "Selectable"
const SELECTED_GROUP_NAME = "Selected"

@export var selected: bool:
	set(v):
		selected = v
		_sync_groups()

func _get_configuration_requirements() -> Array[Variant]: return [Body]

func _ready() -> void:
	_sync_groups()

func _sync_groups() -> void:
	if selected: select()
	else: deselect()

func _enter_tree() -> void:
	E().add_to_group(SELECTABLE_GROUP_NAME)
	select() if selected else deselect()

func _exit_tree() -> void:
	E().remove_from_group(SELECTABLE_GROUP_NAME)
	deselect()

func select() -> void:
	if !is_inside_tree(): return
	E().add_to_group(SELECTED_GROUP_NAME)
	var agent := NodeTools.GetFirstChildOfType(C(Body).get_collision_object(), NavigationAgent3D)
	if agent: agent.avoidance_priority = 1.0

func deselect() -> void:
	if !is_inside_tree(): return
	E().remove_from_group(SELECTED_GROUP_NAME)
	var agent := NodeTools.GetFirstChildOfType(C(Body).get_collision_object(), NavigationAgent3D)
	if agent: agent.avoidance_priority = 0.0
