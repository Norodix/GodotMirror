extends Spatial

class_name TpsCamera


# Nodes
onready var camera_pivot : Spatial = self
onready var camera_rod : Spatial = get_node("CameraRod")
onready var camera : Camera = get_node("CameraRod/MainCamera")

# Movement
export var mouse_sensitivity : float = 0.15
export var camera_min_vertical_rotation : float = -85.0
export var camera_max_vertical_rotation : float = 85.0

# zooming
export var camera_zoom : float = 3.0 setget set_camera_zoom
func set_camera_zoom(value): camera_zoom = clamp(value, camera_min_zoom_distance, camera_max_zoom_distance)
export var camera_min_zoom_distance : float = 3.0
export var camera_max_zoom_distance : float = 15.0
export var camera_zoom_step : float = 0.5

# Cursor
onready var is_cursor_visible setget set_is_cursor_visible, get_is_cursor_visible
func set_is_cursor_visible(value): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED)
func get_is_cursor_visible(): return Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE

var speed = 0.1


#####################
#  Default methods  #
#####################

func _ready() -> void:
	self.is_cursor_visible = false


func _process(delta: float) -> void:
	process_basic_input()
	
	if Input.is_action_pressed("ui_up"):
		self.global_transform.origin += - $CameraRod/MainCamera.global_transform.basis.z * speed
	if Input.is_action_pressed("ui_down"):
		self.global_transform.origin += $CameraRod/MainCamera.global_transform.basis.z * speed
	if Input.is_action_pressed("ui_right"):
		self.global_transform.origin += $CameraRod/MainCamera.global_transform.basis.x * speed
	if Input.is_action_pressed("ui_left"):
		self.global_transform.origin += - $CameraRod/MainCamera.global_transform.basis.x * speed
	#self.transform.origin = lerp(self.transform.origin, player.transform.origin, 0.1)


func _unhandled_input(event: InputEvent) -> void:
	process_mouse_input(event)



####################
#  Camera methods  #
####################


func rotate_camera(camera_direction : Vector2) -> void:
	self.rotation.y += -camera_direction.x
	# Vertical rotation
	camera_rod.rotate_x(-camera_direction.y)
	
	# Limit vertical rotation
	camera_rod.rotation_degrees.x = clamp(
		camera_rod.rotation_degrees.x,
		camera_min_vertical_rotation, camera_max_vertical_rotation
	)
	
	

func toggle_cursor_visibility() -> void:
	self.is_cursor_visible = !self.is_cursor_visible



###################
#  Input methods  #
###################

func process_basic_input():
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_visibility()


func process_mouse_input(event : InputEvent) -> void:
	# Cursor movement
	if event is InputEventMouseMotion:
		var camera_direction = Vector2(
			deg2rad(event.relative.x * mouse_sensitivity),
			deg2rad(event.relative.y * mouse_sensitivity)
		)
		if !self.is_cursor_visible:
			rotate_camera(camera_direction)
	
	# Scrolling
	elif event is InputEventMouseButton:
		if event.is_pressed() and not self.is_cursor_visible:
			if event.button_index == BUTTON_WHEEL_UP:
				self.camera_zoom -= camera_zoom_step
			if event.button_index == BUTTON_WHEEL_DOWN:
				self.camera_zoom += camera_zoom_step
	

