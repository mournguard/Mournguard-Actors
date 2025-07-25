class_name ObjectVector3 extends ActionObject

@export var value: Vector3 = Vector3.ZERO

func _init(_value: Vector3) -> void:
	value = _value

func get_tags() -> Array[Action.Tags]: return [Action.Tags.OBJECT_IS_VECTOR3]

func retrieve() -> Variant: return value

func cancel() -> void: pass

func abort() -> void: pass

func validate() -> bool: return true

func prepare() -> bool: return true

func serialize() -> String:
	return str(value)
