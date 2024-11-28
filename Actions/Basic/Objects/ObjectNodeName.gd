class_name ObjectNodeName extends ActionObject

func get_tags(): return [Action.Tags.OBJECT_IS_STRING]

func retrieve():
	var target = action.subject.retrieve()
	if not target: return ""
	else: return target.name

func validate() -> bool:
	return action.subject.get_tags().has(Action.Tags.SUBJECT_IS_ENTITY)
