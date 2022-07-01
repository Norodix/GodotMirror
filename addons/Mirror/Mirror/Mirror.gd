extends Spatial
tool

const whitegreen : Color = Color(0.9, 0.97, 0.94)

export var size : Vector2 = Vector2(2, 2)
export var ResolutionPerUnit = 600
export(NodePath) var MainCamPath = ""
export(Array, int) var cullMask = []
export(Color, RGB) var MirrorColor = whitegreen

var MainCam : Camera = null
var cam : Camera
var mirror : MeshInstance
var viewport : Viewport

func _enter_tree():
	var node = load("res://addons/Mirror/Mirror/MirrorContainer.tscn").instance()
	add_child(node)

func _ready():
	MainCam = get_node_or_null(MainCamPath)
	cam = $MirrorContainer/Viewport/Camera
	mirror = $MirrorContainer/MeshInstance
	viewport = $MirrorContainer/Viewport
	pass # Replace with function body.

func _process(delta):
	_ready() #Needed for toolscript
	if MainCam == null:
		return
	
	#Cull camera layers
	cam.cull_mask = 0xFF
	for i in cullMask:
		cam.cull_mask &= ~(1<<i)

	mirror.mesh.size = size
	viewport.size = size * ResolutionPerUnit
	
	#Set tint color
	mirror.get_active_material(0).set_shader_param("albedo", MirrorColor)
	
	#Transform the mirror camera to the opposite side of the mirror plane
	var MirrorNormal = mirror.global_transform.basis.z	
	var MirrorTransform =  Mirror_transform(MirrorNormal, mirror.global_transform.origin)
	cam.global_transform = MirrorTransform * MainCam.global_transform
	
	#Look parallel into the mirror plane for frostum camera
	cam.global_transform = cam.global_transform.looking_at(cam.global_transform.origin/2 + MainCam.global_transform.origin/2, \
									mirror.global_transform.basis.y)
	var cam2mirror_offset = mirror.global_transform.origin - cam.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal)) #near plane distance
	near += 0.05 #avoid rendering own surface
	#transform offset to camera's local coordinate system (frostum offset uses local space)
	var cam2mirror_camlocal = cam.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	cam.set_frustum(mirror.mesh.size.x, frostum_offset, near, 10000)
	
# n is the normal of the mirror plane
# d is the offset from the plane of the mirrored object
# Gets the transformation that mirrors through the plane with normal n and offset d
func Mirror_transform(n : Vector3, d : Vector3) -> Transform:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(n.x * n.x, n.x * n.y, n.x * n.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(n.y * n.x, n.y * n.y, n.y * n.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(n.z * n.x, n.z * n.y, n.z * n.z)
	
	var offset = Vector3.ZERO
	offset = 2 * n.dot(d)*n
	
	return Transform(Basis(basisX, basisY, basisZ), offset)	
	pass
