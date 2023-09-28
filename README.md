# Godot Mirror

![mirror](Screenshots/Mirror.png)

This version is compatible with Godot 4.0.1.

A plugin created for godot to instance mirrors in a 3D scene. The mirrors use additional cameras to render the scene from a mirrored perspective.

Mirror properties that can be adjusted:
 - Tint
 - Size
 - Visible visual layers
 - Player camera
 - Distortion

 ## Usage

 After the addon is enabled a custom node is added to godot under the spatial node. 

 Only one camera is supported at a time. At runtime, assign your main camera to the `MirrorManager.main_camera` variable. The plugin adds a secondary camera to the opposite side of the mirror relative to this camera and renders the image to the mirror surface.

 The cull mask array contains the visual layers which are NOT rendered. The render layers numbering is different from their indexing. To avoid rendering layer 1 add a 0 element to the list.
 To avoid rendering layer 2 add a 1 element to the list and so on.

 ## Installation

 Copy the addons/Mirror folder into your godot root directory, same as the asset library installs addons. Enable the plugin in Project settings/Plugins.

 ## Limitations

 Multiple mirrors do not work properly if you can see one mirror in the reflection of the other mirror.
