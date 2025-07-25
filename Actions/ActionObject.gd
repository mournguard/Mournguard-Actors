@abstract class_name ActionObject extends ActionPart
@abstract func get_tags() -> Array[Action.Tags]
@abstract func retrieve() -> Variant
@abstract func cancel() -> void
@abstract func abort() -> void
@abstract func validate() -> bool
@abstract func prepare() -> bool
@abstract func serialize() -> String
