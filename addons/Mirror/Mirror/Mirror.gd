@tool
extends Node3D

const whitegreen : Color = Color(0.9, 0.97, 0.94)

## Size of the mirror in world units
@export var size : Vector2 = Vector2(2, 2)

## Resolution of the rendered viewport is Size*ResolutionPerUnit
@export var ResolutionPerUnit = 100

## The cull mask array contains the visual layers which are NOT rendered. The render layers numbering is different from their indexing. To avoid rendering layer 1 add a 0 element to the list. To avoid rendering layer 2 add a 1 element to the list and so on.
@export var cullMask : Array[int] = []

## Tint color of the mirror surface
@export_color_no_alpha var MirrorColor : Color = whitegreen

## Distortion multiplier of the mirror
@export_range(0, 30, 0.01) var MirrorDistortion = 0

## The distortion texture of the mirror
@export var DistortionTexture: Texture2D

var cam : Camera3D
var mirror : MeshInstance3D
var viewport : SubViewport


func _enter_tree():
	var node = preload("MirrorContainer.tscn").instantiate()
	add_child(node)


func _ready():
	cam = $MirrorContainer/SubViewport/Camera3D
	mirror = $MirrorContainer/MeshInstance3D
	viewport = $MirrorContainer/SubViewport


func _process(delta):
	_ready() # need to reload for proper operation when used as a toolscript
	if Engine.is_editor_hint():
		return
	elif MirrorManager.main_camera == null:
		# No camera specified for the mirror to operate checked
		return
	
	# Cull camera layers
	cam.cull_mask = 0xFF
	for i in cullMask:
		cam.cull_mask &= ~(1<<i)

	# set mirror surface's size
	mirror.mesh.size = size
	# set viewport to specified resolution
	viewport.size = size * ResolutionPerUnit
	
	# Set tint color
	mirror.get_active_material(0).set_shader_parameter("tint", MirrorColor)
	
	# Set distortion texture
	mirror.get_active_material(0).set_shader_parameter("distort_tex", DistortionTexture)
	# Set distortion strength
	mirror.get_active_material(0).set_shader_parameter("distort_strength", MirrorDistortion)
	
	# Transform3D the mirror camera to the opposite side of the mirror plane
	var MirrorNormal = mirror.global_transform.basis.z	
	var MirrorTransform =  Mirror_transform(MirrorNormal, mirror.global_transform.origin)
	cam.global_transform = MirrorTransform * MirrorManager.main_camera.global_transform
	
	# Look perpendicular into the mirror plane for frostum camera
	cam.global_transform = cam.global_transform.looking_at(
			cam.global_transform.origin/2 + MirrorManager.main_camera.global_transform.origin/2, \
			mirror.global_transform.basis.y
		)
	var cam2mirror_offset = mirror.global_transform.origin - cam.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal)) # near plane distance
	near += 0.05 # avoid rendering own surface

	# transform offset to camera's local coordinate system (frostum offset uses local space)
	var cam2mirror_camlocal = cam.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	cam.set_frustum(mirror.mesh.size.x, frostum_offset, near, 10000)


# n is the normal of the mirror plane
# d is the offset from the plane of the mirrored object
# Gets the transformation that mirrors through the plane with normal n and offset d
func Mirror_transform(n : Vector3, d : Vector3) -> Transform3D:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(n.x * n.x, n.x * n.y, n.x * n.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(n.y * n.x, n.y * n.y, n.y * n.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(n.z * n.x, n.z * n.y, n.z * n.z)
	
	var offset = Vector3.ZERO
	offset = 2 * n.dot(d)*n
	
	return Transform3D(Basis(basisX, basisY, basisZ), offset)	
	pass
