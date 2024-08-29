extends VBoxContainer

signal value_changed(value)



@export var value: float = 0.5
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 0.001
@export var exp_edit: bool = false



func _ready():
	$sld_value.min_value = min_value
	$sld_value.max_value = max_value
	$sld_value.step = step
	$sld_value.exp_edit = exp_edit
	$sld_value.value = value
	$sld_value.value_changed.connect(_on_slider_changed)

	$spn_value.min_value = min_value
	$spn_value.max_value = max_value
	$spn_value.step = step
	$spn_value.exp_edit = exp_edit
	$spn_value.value = value
	$spn_value.value_changed.connect(_on_spin_changed)


func _on_slider_changed(_value: float):
	$spn_value.value_changed.disconnect(_on_spin_changed)
	$spn_value.value = _value
	$spn_value.value_changed.connect(_on_spin_changed)
	value = _value
	value_changed.emit(_value)


func _on_spin_changed(_value: float):
	$sld_value.value_changed.disconnect(_on_slider_changed)
	$sld_value.value = _value
	$sld_value.value_changed.connect(_on_slider_changed)
	value = _value
	value_changed.emit(_value)


func set_value_no_cb(_value: float):
	$spn_value.value_changed.disconnect(_on_spin_changed)
	$spn_value.value = _value
	$spn_value.value_changed.connect(_on_spin_changed)
	$sld_value.value_changed.disconnect(_on_slider_changed)
	$sld_value.value = _value
	$sld_value.value_changed.connect(_on_slider_changed)
	value = _value


func set_value(_value: float):
	set_value_no_cb(_value)
	value_changed.emit(_value)


func set_min_value(_value: float):
	$sld_value.min_value = _value
	$spn_value.min_value = _value


func set_max_value(_value: float):
	$sld_value.max_value = _value
	$spn_value.max_value = _value
