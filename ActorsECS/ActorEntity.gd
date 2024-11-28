@tool
class_name ActorEntity extends Entity

var valid_actions: Dictionary[String, Action] = {}

func _ready() -> void:
	super()
	_update_actions()

func _on_child_order_changed():
	super()
	_update_actions()

func _update_actions():
	valid_actions = {}
	for c in get_children():
		if c is ActorComponent:
			var actions = c.get_actions()
			if not actions.is_empty():
				print(valid_actions)
				print(actions)
				valid_actions.merge(actions)
