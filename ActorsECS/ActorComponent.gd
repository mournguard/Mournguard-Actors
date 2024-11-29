@tool
class_name ActorComponent extends Component

func E() -> ActorEntity: return get_parent()

func get_actions() -> Array: return []

func _get_configuration_warnings():
	if not E() or not E() is ActorEntity: return ["[ActorComponent] nodes are only valid as children of [ActorEntity] nodes."]
