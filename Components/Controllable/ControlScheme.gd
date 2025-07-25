@tool
@abstract class_name ControlScheme extends Resource

@abstract func setup(_entity: Entity) -> void
@abstract func teardown(_entity: Entity) -> void
@abstract func on_input(_event: InputEvent, _entity: Entity) -> void
@abstract func on_physics_process(_delta: float, _entity: Entity) -> void
