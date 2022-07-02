# Godot Mirror

![mirror](Demo/Mirror.png)

A plugin created for godot to instance mirrors in a 3D scene. The mirrors use additional cameras to render the scene from a mirrored perspective.

Mirror properties that can be adjusted:
 - Tint
 - Size
 - Visible visual layers
 - Player camera

 ## Usage

 After the addon is enabled a custom node is added to godot under the spatial node. 

 The main camera that renders the scene needs to be selected in the variables of the node. Only one camera is supported at a time. The plugin adds a secondary camera to the opposite side of the mirror relative to this camera and renders the image to the mirror surface.

 The cull mask array contains the visual layers which are NOT rendered. The render layers numbering is different from their indexing. To avoid rendering layer 1 add a 0 element to the list.
 To avoid rendering layer 2 add a 1 element to the list and so on.

 ## Installation

 Copy the addons/Mirror folder into your godot root directory, same as the asset library installs addons. Enable the plugin in Project settings/Plugins.
