class_name Action extends RefCounted

signal ready(action: Action)
signal completed(action: Action)
signal canceled(action: Action)
signal aborted(action: Action)

enum Tags {
	SUBJECT_IS_NULL,
	SUBJECT_IS_ENTITY,
	SUBJECT_IS_ITEM_DROP,
	SUBJECT_IS_ITEM_CONTAINER,
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
var finished: bool = false

func own_parts() -> void:
	subject.action = self
	verb.action = self
	object.action = self

func disown_parts() -> void:
	subject.action = null
	verb.action = null
	object.action = null

func prepare() -> bool:
	if actor.debug: print_debug(actor.E().name + " → Prepare → " + name)

	if verb.get_distance():
		if actor.E().global_position.distance_to(verb.get_position()) > verb.get_distance():
			var dir := verb.get_position() - actor.E().global_position
			var move_action := MoveAction.new(verb.get_position() - dir.normalized() * (verb.get_distance() - actor.C(Body).get_navigation_agent().target_desired_distance))
			move_action.child = self
			actor.insert_action(move_action, self)
			return false

	var is_ready := subject.prepare() and verb.prepare() and object.prepare()

	if is_ready:
		ready.emit(self)

	return is_ready

func update() -> void:
	verb.update()

func execute() -> void:
	if actor.debug: print_debug(actor.E().name + " → Execute → " + name)
	verb.execute()

func validate() -> bool:
	return !finished and subject.validate() and object.validate() and verb.validate()

func complete() -> void:
	if actor.debug: print_debug(actor.E().name + " → Complete → " + name)

	finished = true
	disown_parts()

	completed.emit(self)

func cancel() -> void:
	if actor.debug: print_debug(actor.E().name + " → Cancel → " + name)
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

	finished = true
	disown_parts()

	canceled.emit(self)

func abort() -> void:
	if actor.debug: print_debug(actor.E().name + " → Abort → " + name)

	subject.abort()
	verb.abort()
	object.abort()

	finished = true
	disown_parts()

	aborted.emit(self)

func get_position() -> Vector3:
	return verb.get_position()

func get_distance() -> float:
	return verb.get_distance()

func equals(action: Action) -> bool: return serialize() == action.serialize()

func serialize() -> String:
	return JSON.stringify({
		"subject": subject.serialize(),
		"verb": verb.serialize(),
		"object": object.serialize()
	})
