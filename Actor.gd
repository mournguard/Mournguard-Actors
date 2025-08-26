@tool
class_name Actor extends Component

@export var debug: bool = false

signal action_queue_initialized(action_queue: ActionQueue)
var _action_queue: ActionQueue
var _current_action: Action

func _get_configuration_requirements() -> Array[Variant]: return []

func _ready() -> void:
	if !_action_queue:
		_action_queue = ActionQueue.new(self)
		action_queue_initialized.emit(_action_queue)

	#if E().name == "Unit3D":
		#UI.set_action_queue_actor.call_deferred(self)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return

	if _action_queue.is_empty(): return

	var action: Action = _action_queue.current()

	if busy():
		if _current_action == action:
			_current_action.update()
			if _current_action is MoveAction:
				var next := _action_queue.next()
				if !next or !next.validate(): return
				if next.get_distance():
					if E().global_position.distance_to(next.get_position()) < next.get_distance():
						_current_action.abort()
			elif _current_action.get_distance():
				if E().global_position.distance_to(_current_action.get_position()) > _current_action.get_distance():
					_current_action.abort()
			return
		else:
			_current_action.abort()

	if action:
		if action != _current_action and action.validate():
			connect_action(action)
			if action.prepare():
				_current_action = action
			else:
				disconnect_action(action)
		elif !action.finished:
			action.cancel()

func busy() -> bool:
	return !!_current_action

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
	if _current_action == action:
		_current_action = null

func _on_action_canceled(action: Action) -> void:
	disconnect_action(action)
	if _current_action == action:
		_current_action = null

func _on_action_aborted(action: Action) -> void:
	disconnect_action(action)
	if _current_action == action:
		_current_action = null

func get_action_queue() -> ActionQueue:
	return _action_queue
