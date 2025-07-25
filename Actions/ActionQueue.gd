class_name ActionQueue extends Node

signal changed(actions: Array[Action])

var current: Action

var _actor: Actor
var _actions: Array[Action] = []

func _init(actor: Actor) -> void:
	_actor = actor

func is_empty() -> bool: return _actions.is_empty()

func next() -> Action: return _actions.front() if _actions.size() else null

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

	if current == before:
		_actor.disconnect_action(before)
		current = null

	changed.emit(_actions)

func queue_action(action: Action, clear_queue: bool = false) -> void:
	action.actor = _actor

	if action.instant:
		action.execute()
		return

	if (action.clear_queue or clear_queue) and not Input.is_action_pressed("queue_actions"):
		for a in _actions:
			if a != current:
				a.cancel()

		if current:
			current.abort()
			current = null

		_actions = [action]
	else: _actions.append(action)

	changed.emit(_actions)
