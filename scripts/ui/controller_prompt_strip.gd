class_name ControllerPromptStrip
extends HBoxContainer

const DUALSENSE_ATLAS: Texture2D = preload("res://addons/button_prompts_for_godot/Textures/controller/dualsense.png")
const XBOX_ATLAS: Texture2D = preload("res://addons/button_prompts_for_godot/Textures/controller/xboxSeries.png")
const POSITIONAL_ATLAS: Texture2D = preload("res://addons/button_prompts_for_godot/Textures/controller/positional_prompts.png")
const FONT_UI: FontFile = preload("res://assets/ui/fonts/KenneyFuture.ttf")

const COLOR_TEXT: Color = Color(0.96, 0.91, 0.78, 1.0)
const COLOR_MUTED: Color = Color(0.64, 0.72, 0.74, 1.0)

const FRAME_BY_PROMPT: Dictionary = {
	"confirm": 0,
	"cancel": 1,
	"start": 5,
	"r1": 9,
	"dpad": 10,
}

var prompt_size: int = 34
var text_size: int = 17
var use_short_text: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 12)

func set_prompt_size(new_prompt_size: int, new_text_size: int) -> void:
	prompt_size = new_prompt_size
	text_size = new_text_size
	for child: Node in get_children():
		if child is HBoxContainer:
			_update_item_sizes(child as HBoxContainer)

func set_prompts(items: Array[Dictionary]) -> void:
	for child: Node in get_children():
		child.queue_free()

	for item: Dictionary in items:
		var prompt_id: String = str(item.get("prompt", "confirm"))
		var label_text: String = str(item.get("text", ""))
		add_child(_make_prompt_item(prompt_id, label_text))

func _make_prompt_item(prompt_id: String, label_text: String) -> HBoxContainer:
	var item: HBoxContainer = HBoxContainer.new()
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.alignment = BoxContainer.ALIGNMENT_CENTER
	item.add_theme_constant_override("separation", 6)
	item.set_meta("prompt_id", prompt_id)

	var icon: TextureRect = TextureRect.new()
	icon.name = "PromptIcon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = _make_prompt_texture(prompt_id)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.add_child(icon)

	var label: Label = Label.new()
	label.name = "PromptText"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = label_text.to_upper()
	label.add_theme_font_override("font", FONT_UI)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("outline_size", 3)
	item.add_child(label)

	_update_item_sizes(item)
	return item

func _update_item_sizes(item: HBoxContainer) -> void:
	var icon: TextureRect = item.get_node_or_null("PromptIcon") as TextureRect
	if icon:
		icon.custom_minimum_size = Vector2(prompt_size, prompt_size)

	var label: Label = item.get_node_or_null("PromptText") as Label
	if label:
		label.add_theme_font_size_override("font_size", text_size)

func _make_prompt_texture(prompt_id: String) -> AtlasTexture:
	var atlas_texture: Texture2D = POSITIONAL_ATLAS if prompt_id == "dpad" else _get_controller_atlas()
	var frames_per_row: int = 3 if prompt_id == "dpad" else 5
	var frame_index: int = 0 if prompt_id == "dpad" else int(FRAME_BY_PROMPT.get(prompt_id, 0))
	var frame_width: float = float(atlas_texture.get_width()) / float(frames_per_row)
	var frame_height: float = float(atlas_texture.get_height()) / float(frames_per_row)
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = atlas_texture
	atlas.region = Rect2(
		float(frame_index % frames_per_row) * frame_width,
		float(int(frame_index / frames_per_row)) * frame_height,
		frame_width,
		frame_height
	)
	return atlas

func _get_controller_atlas() -> Texture2D:
	for device_id: int in Input.get_connected_joypads():
		var joy_name: String = Input.get_joy_name(device_id).to_lower()
		if joy_name.contains("xbox") or joy_name.contains("xinput"):
			return XBOX_ATLAS
	return DUALSENSE_ATLAS
