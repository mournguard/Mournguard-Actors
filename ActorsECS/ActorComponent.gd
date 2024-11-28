@tool
class_name ActorComponent extends Component

func get_actions() -> Dictionary[String, Variant]: return {}

func _get_configuration_warnings():
	if not E or not E is ActorEntity: return ["[ActorComponent] nodes are only valid as children of [ActorEntity] nodes."]
