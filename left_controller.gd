extends XRController3D

@export var teleport_spots_parent: Node3D
@export var xr_origin: Node3D
@export var bird_eye_menu_root: Node3D
@export var look_at_target: Node3D
@export var highlight_material: StandardMaterial3D
@export var default_material: StandardMaterial3D

var spots: Array[Node3D] = []
var map_highlights: Array[MeshInstance3D] = []
var selected_index := 0
var bird_eye_active := false

func _ready():
	spots.clear()
	for c in teleport_spots_parent.get_children():
		if c is Node3D:
			spots.append(c)
			for h in c.get_children():
				if h is MeshInstance3D and h.name.begins_with("Highlight") and default_material:
					h.material_override = default_material
					h.visible = true
	_update_map_highlights()
	if bird_eye_menu_root:
		bird_eye_menu_root.visible = false
	selected_index = 0
	_update_highlights()

func _update_map_highlights():
	map_highlights.clear()
	if not bird_eye_menu_root:
		return
	for i in range(bird_eye_menu_root.get_child_count()):
		var child = bird_eye_menu_root.get_child(i)
		if child is MeshInstance3D and child.name.begins_with("Highlight"):
			map_highlights.append(child)

func _open_bird_eye_mode():
	if not bird_eye_menu_root:
		return

	if spots.size() > 0:
		var current_pos_2d = Vector2(xr_origin.global_position.x, xr_origin.global_position.z)
		var closest_spot_index = 0
		var min_dist_sq = -1.0
		
		for i in range(spots.size()):
			var spot_pos_2d = Vector2(spots[i].global_position.x, spots[i].global_position.z)
			var dist_sq = current_pos_2d.distance_squared_to(spot_pos_2d)
			
			if min_dist_sq == -1.0 or dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_spot_index = i
		selected_index = closest_spot_index
	else:
		selected_index = 0

	bird_eye_active = true
	bird_eye_menu_root.visible = true
	_update_highlights()

func _close_menu():
	bird_eye_active = false
	if bird_eye_menu_root:
		bird_eye_menu_root.visible = false
	_reset_highlights()

func _on_next_spot():
	if spots.size() == 0:
		return
	selected_index = (selected_index + 1) % spots.size()
	_update_highlights()

func _on_confirm():
	#print("Confirm pressed, selected_index=", selected_index)
	_perform_teleport()
	_close_menu()

func _on_cancel():
	_close_menu()

func _perform_teleport():
	if spots.size() == 0:
		return
	var target_spot := spots[selected_index]
	xr_origin.global_position = target_spot.global_position
	if look_at_target:
		var flat = Vector3(
			look_at_target.global_position.x,
			xr_origin.global_position.y,
			look_at_target.global_position.z)
		xr_origin.look_at(flat, Vector3.UP, true)

func _update_highlights():
	if spots.size() == 0:
		return
	for s in spots:
		for h in s.get_children():
			if h is MeshInstance3D and h.name.begins_with("Highlight") and default_material:
				h.material_override = default_material
	for mh in map_highlights:
		if mh and default_material:
			mh.material_override = default_material
	var selected = spots[selected_index]
	for h in selected.get_children():
		if h is MeshInstance3D and h.name.begins_with("Highlight") and highlight_material:
			h.material_override = highlight_material
	if selected_index < map_highlights.size() and highlight_material:
		map_highlights[selected_index].material_override = highlight_material

func _reset_highlights():
	for s in spots:
		for h in s.get_children():
			if h is MeshInstance3D and h.name.begins_with("Highlight") and default_material:
				h.material_override = default_material
	for mh in map_highlights:
		if mh and default_material:
			mh.material_override = default_material

func _on_button_pressed(button_name: StringName) -> void:
	#print("Button pressed:", button_name)
	if not bird_eye_active and button_name == "trigger_click":
		_open_bird_eye_mode()
	elif bird_eye_active:
		match button_name:
			"ax_button": _on_next_spot()
			"grip_click": _on_confirm()
			"by_button": _on_cancel()

func _on_button_released(_name: StringName) -> void:
	pass
