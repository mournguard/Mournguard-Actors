@tool
class_name Selectable extends Component

const SINGLE_SELECTION = true
const SELECTABLE_GROUP_NAME = "Selectable"
const SELECTED_GROUP_NAME = "Selected"

@export var selected: bool:
	set(v):
		selected = v
		_sync_groups()

func _get_configuration_requirements() -> Array[Variant]: return [Body]

func _sync_groups() -> void:
	if selected: select()
	else: deselect()

func _enter_tree() -> void:
	E().add_to_group(SELECTABLE_GROUP_NAME)
	select() if selected else deselect()

func _exit_tree() -> void:
	E().remove_from_group(SELECTABLE_GROUP_NAME)
	deselect()

func select(quiet: bool = false) -> void:
	if !is_inside_tree(): return

	if SINGLE_SELECTION:
		var current_selection := get_tree().get_nodes_in_group(SELECTED_GROUP_NAME)
		for s:Entity in current_selection:
			s.C(Selectable).deselect(true)

	E().add_to_group(SELECTED_GROUP_NAME)
	var agent := NodeTools.GetFirstChildOfType(C(Body).get_collision_object(), NavigationAgent3D)
	if agent: agent.avoidance_priority = 1.0

	if !quiet and !Engine.is_editor_hint():
		Signals.entity_selection_changed.emit(get_tree().get_nodes_in_group(SELECTED_GROUP_NAME))

func deselect(quiet: bool = false) -> void:
	if !is_inside_tree(): return

	E().remove_from_group(SELECTED_GROUP_NAME)
	var agent := NodeTools.GetFirstChildOfType(C(Body).get_collision_object(), NavigationAgent3D)
	if agent: agent.avoidance_priority = 0.0

	if !quiet and !Engine.is_editor_hint():
		Signals.entity_selection_changed.emit(get_tree().get_nodes_in_group(SELECTED_GROUP_NAME))
