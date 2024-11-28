class_name Action

signal completed

enum Tags {
	SUBJECT_IS_ENTITY,
	OBJECT_IS_STRING
}

var icon: Texture2D
var name: String
var entity: Entity
var subject: ActionSubject:
	set(v):
		subject = v
		subject.action = self
var verb: ActionVerb:
	set(v):
		verb = v
		verb.action = self
var object: ActionObject:
	set(v):
		object = v
		object.action = self

func _prepare() -> void:
	subject.prepare()
	verb.prepare()
	object.prepare()

func _execute() -> void:
	verb.execute()

func validate(simple: bool = false) -> bool:
	return subject.validate() and verb.validate() and object.validate()

func perform() -> void:
	if validate():
		_prepare()
		_execute()

func complete() -> void:
	completed.emit()
