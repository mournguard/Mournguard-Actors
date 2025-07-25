class_name ObjectNodeName extends ActionObject

func get_tags() -> Array[Action.Tags]: return [Action.Tags.OBJECT_IS_STRING]

func retrieve() -> Variant:
	var target: Variant = action.subject.retrieve()
	if not target: return ""
	else: return target.name

func cancel() -> void: pass

func abort() -> void: pass

func validate() -> bool: return true

func prepare() -> bool: return true

func serialize() -> String:
	return retrieve()
