class_name SubjectEntity extends ActionSubject

var subject: Entity

func _init(_subject: Entity) -> void:
	subject = _subject

func get_tags() -> Array[Action.Tags]: return [Action.Tags.SUBJECT_IS_ENTITY]

func retrieve() -> Variant: return subject

func cancel() -> void: pass

func abort() -> void: pass

func validate() -> bool: return subject != null

func prepare() -> bool: return true

func serialize() -> String:
	return str(subject.unique_id)
