@tool
class_name ControlSchemeClickToMove extends ControlScheme

const MOVEMENT_INDICATOR = preload("res://VFX/MovementIndicator.tscn")

var _indicator: GPUParticles3D

func setup(entity: Entity) -> void:
	if Engine.is_editor_hint(): return
	if !_indicator:
		_indicator = MOVEMENT_INDICATOR.instantiate()

	if !_indicator.is_inside_tree():
		(func() -> void: entity.get_tree().current_scene.add_child(_indicator)).call_deferred()

func teardown(_entity: Entity) -> void:
	if Engine.is_editor_hint(): return

	if _indicator:
		_indicator.queue_free()

func on_input(event: InputEvent, _entity: Entity) -> void:
	if Engine.is_editor_hint(): return

	if event is InputEventMouseButton and event.is_released():
		var raycast := Game.click_ray(event.position)
		if raycast and raycast.collider:

			# Do not proceed if the click was on a 3D UI element and assume it will handle it.
			if raycast.collider.collision_layer == 0b1000:
				return

			# Do not process if the click was on an Interactable and assume it will handle it.
			if Body.IsBodyCollider(raycast.collider):
				if raycast.collider.get_parent().get_parent().C(Interactable):
					return

			if event.button_index == MOUSE_BUTTON_LEFT:
				var xform: Transform3D = Transform3D.IDENTITY

				if raycast.position:
					xform = Transform3D(Basis.IDENTITY, raycast.position)
					_indicator.global_position = xform.origin
					_indicator.emit_particle(xform, Vector3.ZERO, Color.TRANSPARENT, Color.TRANSPARENT, GPUParticles3D.EMIT_FLAG_POSITION)
					var move := MoveAction.new(xform.origin)
					_entity.C(Actor).queue_action(move)

func on_physics_process(_delta: float, _entity: Entity) -> void:
	pass
