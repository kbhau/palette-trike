extends TextureRect

var swatchsize = 48

var img: Image = Image.new()

var rows: Array[colour_strip] = []

func _ready() -> void:
	img = Image.create(1024, 1024, false, Image.FORMAT_RGB8)


func get_final_image() -> Image:
	var vsize = 2 + (swatchsize + 2) * rows.size()
	var max_steps = 3
	for row in rows:
		if row.steps > max_steps:
			max_steps = row.steps
	var hsize = 2 + (swatchsize + 2) * max_steps
	
	var expimg = Image.create(hsize, vsize, false, Image.FORMAT_RGB8)
	expimg.fill(Color(0,0,0))
	
	var oy = 2
	for row in rows:
		var ox = 2
		
		var ok1 = rgb_to_oklab(row.c1.r, row.c1.g, row.c1.b)
		var ok2 = rgb_to_oklab(row.c2.r, row.c2.g, row.c2.b)
		var ok3 = rgb_to_oklab(row.c3.r, row.c3.g, row.c3.b)
		
		var res = []
		if row.curve in [0, 1]:
			res = get_points_simple(ok1, ok2, ok3, row.curve, row.steps)
		elif row.curve in [2, 3]:
			res = get_points_resampled(ok1, ok2, ok3, row.curve, row.steps, row.samples)
		
		for i in range(row.steps):
			expimg.fill_rect(Rect2(ox, oy, swatchsize, swatchsize), oklab_to_rgb(res[i].x, res[i].y, res[i].z))
			ox += swatchsize + 2
		oy += swatchsize + 2

	return expimg


func _draw():
	draw_rect(Rect2(0, 0, 1024, 1024), Color(0,0,0))
	
	var oy = 2
	for row in rows:
		var ox = 2
		
		var ok1 = rgb_to_oklab(row.c1.r, row.c1.g, row.c1.b)
		var ok2 = rgb_to_oklab(row.c2.r, row.c2.g, row.c2.b)
		var ok3 = rgb_to_oklab(row.c3.r, row.c3.g, row.c3.b)
		
		var res = []
		if row.curve in [0, 1]:
			res = get_points_simple(ok1, ok2, ok3, row.curve, row.steps)
		elif row.curve in [2, 3]:
			res = get_points_resampled(ok1, ok2, ok3, row.curve, row.steps, row.samples)
		
		for i in range(row.steps):
			draw_rect(Rect2(ox, oy, swatchsize, swatchsize), oklab_to_rgb(res[i].x, res[i].y, res[i].z))
			ox += swatchsize + 2
		oy += swatchsize + 2


func get_points_simple(p0: Vector3, p1: Vector3, p2: Vector3, curve: int, steps: int):
	var result = []
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		if curve == 0:
			result.append(bezier_curve3d(t, p0, p1, p2))
		elif curve == 1:
			result.append(interpolated_curve3d(t, p0, p1, p2))
	return result


func get_points_resampled(p0: Vector3, p1: Vector3, p2: Vector3, curve: int, steps: int, num_samples: int):
	#var num_samples = 100  # Number of samples to approximate the arc length
	var t_values_dense = []
	var curve_points_dense = []
	for i in range(num_samples + 1):
		var t = i / float(num_samples)
		t_values_dense.append(t)
		if curve == 2:
			curve_points_dense.append(bezier_curve3d(t, p0, p1, p2))
		elif curve == 3:
			curve_points_dense.append(interpolated_curve3d(t, p0, p1, p2))

	# Step 1: Compute cumulative arc lengths
	var cumulative_arc_length = [0.0]  # Start with 0 for the first point
	for i in range(1, len(curve_points_dense)):
		cumulative_arc_length.append(cumulative_arc_length[i - 1] + distance3d(curve_points_dense[i], curve_points_dense[i - 1]))

	# Step 2: Normalize the arc length to [0, 1]
	var total_length = cumulative_arc_length[-1]
	var normalized_arc_length = []
	for length in cumulative_arc_length:
		normalized_arc_length.append(length / total_length)

	# Step 3: Find evenly spaced arc lengths
	var evenly_spaced_lengths = []
	for i in range(steps):
		evenly_spaced_lengths.append(i / float(steps - 1))

	# Step 4: Resample the curve at these evenly spaced arc lengths
	var resampled_points = []
	for target_length in evenly_spaced_lengths:
		var closest_index = 0
		for j in range(len(normalized_arc_length)):
			if normalized_arc_length[j] >= target_length:
				closest_index = j
				break
		resampled_points.append(curve_points_dense[closest_index])

	return resampled_points


# A function to calculate the distance between two points
func distance1d(p1: float, p2: float) -> float:
	return abs(p1 - p2)
func distance2d(p1: Vector2, p2: Vector2) -> float:
	return p1.distance_to(p2)
func distance3d(p1: Vector3, p2: Vector3) -> float:
	return p1.distance_to(p2)


# A function to calculate the quadratic Bezier curve
# t - [0..1]
func bezier_curve1d(t: float, p0: float, p1: float, p2: float) -> float:
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2
func bezier_curve2d(t: float, p0: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2
func bezier_curve3d(t: float, p0: Vector3, p1: Vector3, p2: Vector3) -> Vector3:
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2
func interpolated_curve1d(t: float, p0: float, p1: float, p2: float) -> float:
	return p0 * (1 - t) * (1 - 2 * t) + p1 * 4 * t * (1 - t) + p2 * t * (2 * t - 1)
func interpolated_curve2d(t: float, p0: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	return p0 * (1 - t) * (1 - 2 * t) + p1 * 4 * t * (1 - t) + p2 * t * (2 * t - 1)
func interpolated_curve3d(t: float, p0: Vector3, p1: Vector3, p2: Vector3) -> Vector3:
	return p0 * (1 - t) * (1 - 2 * t) + p1 * 4 * t * (1 - t) + p2 * t * (2 * t - 1)


# RGB to Oklab Conversion Function
func rgb_to_oklab(r: float, g: float, b: float) -> Vector3:
	# Convert RGB to Linear RGB
	var r_lin = rgb_to_linear(r)
	var g_lin = rgb_to_linear(g)
	var b_lin = rgb_to_linear(b)
	
	# Linear RGB to LMS space
	var l = 0.4122214708 * r_lin + 0.5363325363 * g_lin + 0.0514459929 * b_lin
	var m = 0.2119034982 * r_lin + 0.6806995451 * g_lin + 0.1073969566 * b_lin
	var s = 0.0883024619 * r_lin + 0.2817188376 * g_lin + 0.6299787005 * b_lin

	# Non-linear transformation
	var l_cubed = pow(l, 1.0/3.0)
	var m_cubed = pow(m, 1.0/3.0)
	var s_cubed = pow(s, 1.0/3.0)

	# Convert to Oklab
	var L = 0.2104542553 * l_cubed + 0.7936177850 * m_cubed - 0.0040720468 * s_cubed
	var a = 1.9779984951 * l_cubed - 2.4285922050 * m_cubed + 0.4505937099 * s_cubed
	var _b = 0.0259040371 * l_cubed + 0.7827717662 * m_cubed - 0.8086757660 * s_cubed

	return Vector3(L, a, _b)


# Helper function to convert sRGB to Linear RGB
func rgb_to_linear(x: float) -> float:
	if x <= 0.04045:
		return x / 12.92
	return pow((x + 0.055) / 1.055, 2.4)


# Oklab to RGB Conversion Function
func oklab_to_rgb(L: float, a: float, b: float) -> Color:
	# Convert Oklab to LMS space
	var l_cubed = L + 0.3963377774 * a + 0.2158037573 * b
	var m_cubed = L - 0.1055613458 * a - 0.0638541728 * b
	var s_cubed = L - 0.0894841775 * a - 1.2914855480 * b

	var l = pow(l_cubed, 3.0)
	var m = pow(m_cubed, 3.0)
	var s = pow(s_cubed, 3.0)

	# Convert LMS to Linear RGB
	var r_lin = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
	var g_lin = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
	var b_lin = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

	# Linear RGB to sRGB
	var r = linear_to_rgb(r_lin)
	var g = linear_to_rgb(g_lin)
	var _b = linear_to_rgb(b_lin)

	return Color(r, g, _b)


# Helper function to convert Linear RGB to sRGB
func linear_to_rgb(x: float) -> float:
	if x <= 0.0031308:
		return 12.92 * x
	return 1.055 * pow(x, 1.0 / 2.4) - 0.055
