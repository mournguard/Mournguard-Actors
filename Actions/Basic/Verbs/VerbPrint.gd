class_name VerbPrint extends ActionVerb

func execute() -> void:
	print(action.object.retrieve())
	action.complete()
