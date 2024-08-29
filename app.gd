extends Control

var current = 0

var rows: Array[colour_strip] = [
	colour_strip.new()
]


func _ready() -> void:
	%series.item_clicked.connect(_series_clicked)
	%btn_add.pressed.connect(_strip_add)
	%btn_remove.pressed.connect(_strip_remove)
	%btn_load.pressed.connect(_btn_load)
	%btn_save.pressed.connect(_btn_save)
	%btn_export.pressed.connect(_btn_export)
	%btn_up.pressed.connect(_btn_up)
	%btn_dn.pressed.connect(_btn_dn)
	%pkr_low.color_changed.connect(_color_changed_1)
	%pkr_mid.color_changed.connect(_color_changed_2)
	%pkr_high.color_changed.connect(_color_changed_3)
	%val_steps.value_changed.connect(_steps_changed)
	%val_samples.value_changed.connect(_samples_changed)
	%opt_curve_type.item_selected.connect(_curve_selected)
	%txt_name.text_changed.connect(_name_changed)
	%dlg_save.file_selected.connect(_btn_save_core)
	%dlg_load.file_selected.connect(_btn_load_core)
	%dlg_export.file_selected.connect(_btn_export_core)
	current = 0
	_series_clicked(current, Vector2(), 0)


func _btn_load():
	%dlg_load.popup_centered()
	
func _btn_load_core(path: String):
	var f = FileAccess.open(path, FileAccess.READ)
	var num = f.get_32()
	rows = []
	for i in range(num):
		var p = colour_strip.new()
		p.name = f.get_var()
		p.c1 = f.get_var()
		p.c2 = f.get_var()
		p.c3 = f.get_var()
		p.curve = f.get_var()
		p.samples = f.get_var()
		p.steps = f.get_var()
		rows.append(p)
	f.close()
	#rows = f.get_var(true)
	#var json = JSON.new()
	#var res = json.parse(f.get_line())
	#if res != OK:
		#return
	#rows = json.get_data()
	redo_list()
	%series.select(0)
	update_pal()


func _btn_save():
	%dlg_save.popup_centered()

func _btn_save_core(path: String):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_32(rows.size())
	for row in rows:
		f.store_var(row.name)
		f.store_var(row.c1)
		f.store_var(row.c2)
		f.store_var(row.c3)
		f.store_var(row.curve)
		f.store_var(row.samples)
		f.store_var(row.steps)
	f.close()


func _btn_export():
	%dlg_export.popup_centered()

func _btn_export_core(path: String):
	%out.rows = rows
	var img: Image = %out.get_final_image()
	img.save_png(path)


func _btn_up():
	if current <= 0:
		return
	var last = current
	current -= 1
	var temp = rows[current]
	rows[current] = rows[last]
	rows[last] = temp
	redo_list()
	%series.select(current)
	update_pal()


func _btn_dn():
	if current >= rows.size()-1:
		return
	var last = current
	current += 1
	var temp = rows[current]
	rows[current] = rows[last]
	rows[last] = temp
	redo_list()
	%series.select(current)
	update_pal()


func redo_list():
	%series.clear()
	for r in rows:
		%series.add_item(r.name)


func update_pal() -> void:
	%out.rows = rows
	%out.queue_redraw()


func _strip_add():
	current += 1
	rows.insert(current, colour_strip.new())
	var id = %series.add_item(rows[current].name)
	%series.move_item(id, current)
	%series.select(current)
	_series_clicked(current, Vector2(), 0)
	#update_pal()


func _strip_remove():
	if rows.size() <= 1:
		return
	rows.remove_at(current)
	%series.remove_item(current)
	current -= 1
	if current < 0:
		current = 0
	%series.select(current)
	_series_clicked(current, Vector2(), 0)
	#update_pal()


func _series_clicked(index: int, _at_position: Vector2, _mouse_button_index: int):
	current = index
	var s = rows[current]
	%pkr_low.color_changed.disconnect(_color_changed_1)
	%pkr_mid.color_changed.disconnect(_color_changed_2)
	%pkr_high.color_changed.disconnect(_color_changed_3)
	%val_steps.value_changed.disconnect(_steps_changed)
	%val_samples.value_changed.disconnect(_samples_changed)
	%opt_curve_type.item_selected.disconnect(_curve_selected)
	%txt_name.text_changed.disconnect(_name_changed)
	%pkr_low.color = s.c1
	%pkr_mid.color = s.c2
	%pkr_high.color = s.c3
	%val_steps.set_value(s.steps)
	%val_samples.set_value(s.samples)
	%opt_curve_type.selected = s.curve
	%txt_name.text = s.name
	%pkr_low.color_changed.connect(_color_changed_1)
	%pkr_mid.color_changed.connect(_color_changed_2)
	%pkr_high.color_changed.connect(_color_changed_3)
	%val_steps.value_changed.connect(_steps_changed)
	%val_samples.value_changed.connect(_samples_changed)
	%opt_curve_type.item_selected.connect(_curve_selected)
	%txt_name.text_changed.connect(_name_changed)
	update_pal()


func _name_changed(value: String):
	rows[current].name = value
	%series.set_item_text(current, value)

func _color_changed_1(colour: Color):
	rows[current].c1 = colour
	update_pal()

func _color_changed_2(colour: Color):
	rows[current].c2 = colour
	update_pal()

func _color_changed_3(colour: Color):
	rows[current].c3 = colour
	update_pal()

func _steps_changed(value):
	rows[current].steps = value
	update_pal()

func _samples_changed(value):
	rows[current].samples = value
	update_pal()

func _curve_selected(value):
	rows[current].curve = value
	update_pal()
