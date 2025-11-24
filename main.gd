extends Node3D

var xr_interface: XRInterface

func _ready():
	# 1) See what XR interfaces Godot finds at all
	var interfaces = XRServer.get_interfaces()
	print("XR interfaces found: ", interfaces)

	
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface:
		print("Found OpenXR interface: ", xr_interface.get_name())
		get_viewport().use_xr = true
	else:
		print("OpenXR interface not found (XRServer.find_interface returned null)")
