class_name SubjectRaw extends ActionSubject

var subject: Node

func _init(_subject: Entity) -> void:
	subject = _subject

func get_tags(): return [Action.Tags.SUBJECT_IS_ENTITY]

func retrieve(): return subject
