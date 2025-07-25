@tool
class_name Actor extends Component

@export var debug: bool = false

signal action_queue_initialized
var _action_queue: ActionQueue

func _get_configuration_requirements() -> Array[Variant]: return []

func _ready() -> void:
	if !_action_queue:
		_action_queue = ActionQueue.new(self)
		action_queue_initialized.emit()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return

	if busy():
		_action_queue.current.update()
		return

	if _action_queue.is_empty(): return

	var action: Action = _action_queue.next()

	if action.validate():
		connect_action(action)
		_action_queue.current = action
		action.prepare()
	else:
		action.cancel()

func busy() -> bool:
	return !!_action_queue.current

func insert_action(action: Action, before: Action) -> void:
	_action_queue.insert_action(action, before)

func queue_action(action: Action, clear_queue: bool = false) -> void:
	_action_queue.queue_action(action, clear_queue)

func connect_action(action: Action) -> void:
	action.ready.connect(_on_action_ready)
	action.completed.connect(_on_action_completed)
	action.canceled.connect(_on_action_canceled)
	action.aborted.connect(_on_action_aborted)

func disconnect_action(action: Action) -> void:
	action.ready.disconnect(_on_action_ready)
	action.completed.disconnect(_on_action_completed)
	action.canceled.disconnect(_on_action_canceled)
	action.aborted.disconnect(_on_action_aborted)

func _on_action_ready(action: Action) -> void:
	action.execute()

func _on_action_completed(action: Action) -> void:
	disconnect_action(action)
	_action_queue.erase(action)
	_action_queue.current = null

func _on_action_canceled(action: Action) -> void:
	disconnect_action(action)
	_action_queue.erase(action)
	_action_queue.current = null

func _on_action_aborted(action: Action) -> void:
	disconnect_action(action)
	_action_queue.erase(action)
	_action_queue.current = null

func get_action_queue() -> ActionQueue:
	return _action_queue
