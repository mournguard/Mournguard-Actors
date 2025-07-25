class_name Action extends RefCounted

signal ready(action: Action)
signal completed(action: Action)
signal canceled(action: Action)
signal aborted(action: Action)

enum Tags {
	SUBJECT_IS_NULL,
	SUBJECT_IS_ENTITY,
	SUBJECT_IS_ITEM_DROP,
	SUBJECT_IS_ABILITY_TARGET,
	OBJECT_IS_NULL,
	OBJECT_IS_STRING,
	OBJECT_IS_VECTOR3,
	OBJECT_IS_ABILITY,
}

static func Construct(_actor: Actor = null, _object: ActionObject = null, _verb: ActionVerb = null, _subject: ActionSubject = null, _instant: bool = false, _parent: Action = null, _child: Action = null) -> Action:
	var action := Action.new()
	action.actor = _actor
	if _object: _object.action = action
	if _verb: _verb.action = action
	if _subject: _subject.action = action
	action.object = _object
	action.verb = _verb
	action.subject = _subject
	action.parent = _parent
	action.child = _child
	action.instant = _instant
	return action

var actor: Actor
var parent: Action
var child: Action

@export var icon: Texture2D
@export var name: String:
	get():
		return name if name else verb.get_script().get_global_name()
@export var instant: bool
@export var clear_queue: bool

var subject: ActionSubject
var verb: ActionVerb
var object: ActionObject

func own_parts() -> void:
	subject.action = self
	verb.action = self
	object.action = self

func prepare() -> bool:
	if actor.debug: print_debug(actor.E().name + " → Prepare → " + get_script().get_global_name())

	var is_ready := subject.prepare() and verb.prepare() and object.prepare()

	if is_ready:
		ready.emit(self)

	return is_ready

func update() -> void:
	verb.update()

func execute() -> void:
	if actor.debug: print_debug(actor.E().name + " → Execute → " + get_script().get_global_name())
	verb.execute()

func validate() -> bool:
	return subject.validate() and verb.validate() and object.validate()

func complete() -> void:
	if actor.debug: print_debug(actor.E().name + " → Complete → " + get_script().get_global_name())
	completed.emit(self)

func cancel() -> void:
	if actor.debug: print_debug(actor.E().name + " → Cancel → " + get_script().get_global_name())
	var c:Action = self

	var chain: Array[Action] = []
	while c.child:
		chain.insert(0, c.child)
		c = c.child

	for action in chain:
		action.cancel()

	subject.cancel()
	verb.cancel()
	object.cancel()

	canceled.emit(self)

func abort() -> void:
	if actor.debug: print_debug(actor.E().name + " → Abort → " + get_script().get_global_name())
	var c:Action = self

	var chain: Array[Action] = []
	while c.child:
		chain.insert(0, c.child)
		c = c.child

	for action in chain:
		action.abort()

	subject.abort()
	verb.abort()
	object.abort()

	aborted.emit(self)

func equals(action: Action) -> bool: return serialize() == action.serialize()

func serialize() -> String:
	return JSON.stringify({
		"subject": subject.serialize(),
		"verb": verb.serialize(),
		"object": object.serialize()
	})
