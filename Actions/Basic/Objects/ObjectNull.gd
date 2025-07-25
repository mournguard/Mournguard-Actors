class_name ObjectNull extends ActionObject

func get_tags() -> Array[Action.Tags]: return [Action.Tags.OBJECT_IS_NULL]

func retrieve() -> Variant: return null

func cancel() -> void: pass

func abort() -> void: pass

func validate() -> bool: return true

func prepare() -> bool: return true

func serialize() -> String:
	return ""
