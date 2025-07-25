class_name VerbPrint extends ActionVerb

func execute() -> void:
	print(action.object.retrieve())
	action.complete()

func cancel() -> void: pass

func abort() -> void: pass

func validate() -> bool: return true

func update() -> void: pass

func prepare() -> bool: return true

func get_distance() -> float: return 0

func serialize() -> String:
	return "VerbPrint"
