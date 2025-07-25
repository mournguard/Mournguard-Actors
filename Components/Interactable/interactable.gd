@tool
class_name Interactable extends Component

static var RadialMenuTarget: Entity
static var HoveredInteractable: Interactable

static func ToggleHighlights(enabled: bool) -> void:
	for interactable: Interactable in Game.get_tree().get_nodes_in_group("Interactable"):
		interactable.highlight_on() if enabled else interactable.highlight_off()

static func ResetHighlights() -> void:
	for interactable: Interactable in Game.get_tree().get_nodes_in_group("Interactable"):
		if interactable._highlight_locks.is_locked:
			interactable.highlight_on()
		else:
			interactable.highlight_off()

func _get_configuration_requirements() -> Array[Variant]: return [Body, Highlight]

@export var radial_menu_renderer: RadialMenuRenderer

signal hover_changed(hovered: bool)

var _menu: RadialMenu
var _highlight_locks: LockList = LockList.new()

func _ready() -> void:
	add_to_group("Interactable")
	C(Body).get_collision_object().mouse_entered.connect(on_mouse_entered)
	C(Body).get_collision_object().mouse_exited.connect(on_mouse_exited)
	C(Body).get_collision_object().input_event.connect(_on_input_event)

	_highlight_locks.unlocked.connect(highlight_off)
	_highlight_locks.locked.connect(highlight_on)

func _exit_tree() -> void:
	if _menu: _menu.close()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_interaction_display"):
		if Controllable.Locks.is_locked:
			return
		_highlight_locks.lock(Keybinds.InteractionDisplayLock)
	elif event.is_action_released("toggle_interaction_display"):
		_highlight_locks.unlock(Keybinds.InteractionDisplayLock)

func on_mouse_entered(fake: bool = false) -> void:
	if !fake and HoveredInteractable != self:
		HoveredInteractable = self
	hover_changed.emit(true)
	_highlight_locks.lock(Lock.MouseOverLock)

func on_mouse_exited(fake: bool = false) -> void:
	if !fake and HoveredInteractable == self:
		HoveredInteractable = null
	hover_changed.emit(false)
	_highlight_locks.unlock(Lock.MouseOverLock)

func highlight_on() -> void:
	if Controllable.Locks.is_locked:
		return

	if C(Highlight):
		C(Highlight).visible = true

func highlight_off() -> void:
	if C(Highlight):
		C(Highlight).visible = false

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if Controllable.Locks.is_locked:
		return

	if not radial_menu_renderer: return
	if event is InputEventMouseButton and event.is_released():
		var menu_options := get_options()

		if event.button_index == MOUSE_BUTTON_LEFT:
			if RadialMenu.IsOpened(): RadialMenu.Close()
			else: menu_options[radial_menu_renderer.get_main_option_index()].callable.call()

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if RadialMenu.IsOpened(): RadialMenu.Close()

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if !RadialMenu.IsOpened(): open_radial_menu(event.position)

func open_radial_menu(position: Vector2) -> void:
	var menu_options := get_options()
	_menu = RadialMenu.Open(menu_options, position, E().C(Body).get_collision_object())
	RadialMenuTarget = E()
	_menu.tree_exited.connect(func() -> void:
		RadialMenuTarget = null
	)

func get_options() -> Array:
	var character := Game.get_character()
	if !character: return []
	var menu_options := radial_menu_renderer.get_options(self, character.C(Actor))
	if menu_options.is_empty(): return []
	return menu_options

func interact() -> void:
	var menu_options := get_options()
	if menu_options.is_empty(): return
	menu_options[radial_menu_renderer.get_main_option_index()].callable.call()
