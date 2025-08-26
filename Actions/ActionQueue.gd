class_name ActionQueue extends Node

signal changed(actions: Array[Action])

var _actor: Actor
var _actions: Array[Action] = []

func _init(actor: Actor) -> void:
	_actor = actor

func is_empty() -> bool: return _actions.is_empty()

func current() -> Action: return _actions.front() if _actions.size() else null

func next() -> Action: return _actions[1] if _actions.size() > 1 else null

func erase(action: Action) -> void:
	_actions.erase(action)
	changed.emit(_actions)

func insert_action(action: Action, before: Action) -> void:
	action.actor = _actor

	if action.instant:
		action.execute()
		return

	var index := _actions.find(before)
	if index != -1:
		_actions.insert(index, action)
		connect_action(action)

	changed.emit(_actions)

func queue_action(action: Action, clear_queue: bool = false) -> void:
	action.actor = _actor

	if action.instant:
		action.execute()
		return

	if (action.clear_queue or clear_queue) and not Input.is_action_pressed("queue_actions"):
		for a in _actions:
			if a == current():
				current().abort()
			else:
				a.cancel()
		_actions = []

	_actions.append(action)
	connect_action(action)

	changed.emit(_actions)

func connect_action(action: Action) -> void:
	action.completed.connect(_on_action_completed)
	action.canceled.connect(_on_action_canceled)
	action.aborted.connect(_on_action_aborted)

func disconnect_action(action: Action) -> void:
	action.completed.disconnect(_on_action_completed)
	action.canceled.disconnect(_on_action_canceled)
	action.aborted.disconnect(_on_action_aborted)

func _on_action_completed(action: Action) -> void:
	disconnect_action(action)
	erase(action)

func _on_action_canceled(action: Action) -> void:
	disconnect_action(action)
	erase(action)

func _on_action_aborted(action: Action) -> void:
	disconnect_action(action)
	erase(action)
