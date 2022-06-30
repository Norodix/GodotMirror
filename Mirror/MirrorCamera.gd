tool
extends Viewport

export var MainCamPath = ""
var MainCam : Camera = null
var cam : Camera
var mirror : MeshInstance


# Called when the node enters the scene tree for the first time.
func _ready():
	MainCam = get_node_or_null(get_parent().get("MainCamPath"))
	cam = $Camera
	mirror = get_node_or_null("../MeshInstance")
	pass # Replace with function body.

func _process(delta):
	_ready()
	if MainCam == null:
		return
	self.size = Vector2(mirror.mesh.size.x, mirror.mesh.size.y) * 1000
	#get relative transformation of cam
	var MainCamRelTransform : Transform = mirror.global_transform.affine_inverse() * MainCam.global_transform
	var MirrorNormal = mirror.global_transform.basis.z	
	var MirrorTransform =  Mirror_transform(MirrorNormal, mirror.global_transform.origin)
	cam.global_transform = MirrorTransform * MainCam.global_transform
	
	#Look parallel into the mirror plane for frostum camera
	cam.global_transform = cam.global_transform.looking_at(cam.global_transform.origin/2 + MainCam.global_transform.origin/2, \
									Vector3.UP)
	var cam2mirror_offset = mirror.global_transform.origin - cam.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal))
	#transform offset to camera's local coordinate system
	var cam2mirror_camlocal = cam.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	cam.set_frustum(mirror.mesh.size.x, frostum_offset, near, 10000)
	
#n is the normal of the mirror plane
#d is the offset from the plane of the mirrored object
func Mirror_transform(n : Vector3, d : Vector3) -> Transform:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(n.x * n.x, n.x * n.y, n.x * n.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(n.y * n.x, n.y * n.y, n.y * n.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(n.z * n.x, n.z * n.y, n.z * n.z)
	
	var offset = Vector3.ZERO
	offset = 2 * n.dot(d)*n
	
	return Transform(Basis(basisX, basisY, basisZ), offset)	
	pass
