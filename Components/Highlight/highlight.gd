@tool
class_name Highlight extends Component

static var MATERIAL_PARTY := preload("uid://bk6x5i8rogq3r").duplicate()
static var MATERIAL_FRIENDLY := preload("uid://bk6x5i8rogq3r").duplicate()
static var MATERIAL_NEUTRAL := preload("uid://bk6x5i8rogq3r").duplicate()
static var MATERIAL_ENEMY := preload("uid://bk6x5i8rogq3r").duplicate()
static var MATERIAL_OBJECT := preload("uid://bk6x5i8rogq3r").duplicate()

func _get_configuration_requirements() -> Array[Variant]: return [Body]

@export var meshes: Array[GeometryInstance3D] = []

@export var visible: bool:
	set(_v):
		visible = _v
		_sync_visible()

var material := MATERIAL_NEUTRAL

func _ready() -> void:
	_sync_visible()

func _sync_visible() -> void:
	if visible: _turn_on()
	else: _turn_off()

func _turn_on() -> void:
	for mesh in meshes:
		mesh.material_overlay = material

func _turn_off() -> void:
	for mesh in meshes:
		mesh.material_overlay = null
