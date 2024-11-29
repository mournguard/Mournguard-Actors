@tool
class_name ActorEntity extends Entity

var valid_actions: Array = []

func _ready() -> void:
	super()
	_update_actions()

func _on_child_order_changed():
	super()
	_update_actions()

func _update_actions():
	valid_actions = []
	for c in get_children():
		if c is ActorComponent:
			var actions = c.get_actions()
			if not actions.is_empty():
				valid_actions.append_array(actions)
