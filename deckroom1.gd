extends Control

# ตัวแปรเก็บสถานะ
var local_decks = {}
var all_cards = []
var all_cores = []
var selected_deck = "deck1"
var selected_card: String = ""

# เงื่อนไขจำนวนสูงสุดของการ์ดแต่ละระดับ
const CARD_LIMITS = {
	"only one": {"per_card": 1, "total": 3},
	"only two": {"per_card": 2, "total": 10},
	"only three": {"per_card": 3, "total": 12},
	"common": {"per_card": 5, "total": 20}
}

# ไฟล์ข้อมูล
const DECK_FILE = "user://deck_data.json"
const CARDS_FILE = "res://cards.json"
const CORES_FILE = "res://universal_cores.json"

# ฟังก์ชันเริ่มต้น
func _ready() -> void:
	initialize_deck_file()
	load_cards_and_cores()
	load_local_decks()
	connect_signals()
	update_ui()

# ฟังก์ชันเชื่อม Signal
func connect_signals():
	if not $AddCardButton.is_connected("pressed", Callable(self, "_on_add_card_pressed")):
		$AddCardButton.connect("pressed", Callable(self, "_on_add_card_pressed"))

	if not $RemoveCardButton.is_connected("pressed", Callable(self, "_on_remove_card_pressed")):
		$RemoveCardButton.connect("pressed", Callable(self, "_on_remove_card_pressed"))

	if not $DeckPanel/Deck1Container/Deck1.is_connected("pressed", Callable(self, "_on_deck_1_pressed")):
		$DeckPanel/Deck1Container/Deck1.connect("pressed", Callable(self, "_on_deck_1_pressed"))

	if not $DeckPanel/Deck2Container/Deck2.is_connected("pressed", Callable(self, "_on_deck_2_pressed")):
		$DeckPanel/Deck2Container/Deck2.connect("pressed", Callable(self, "_on_deck_2_pressed"))

	if not $DeckPanel/Deck3Container/Deck3.is_connected("pressed", Callable(self, "_on_deck_3_pressed")):
		$DeckPanel/Deck3Container/Deck3.connect("pressed", Callable(self, "_on_deck_3_pressed"))

# คัดลอกไฟล์ deck_data.json จาก res:// ไปยัง user:// หากยังไม่มี
func initialize_deck_file():
	if not FileAccess.file_exists(DECK_FILE):
		print("Deck file not found in user://. Copying default deck_data.json from res://.")
		copy_file("res://deck_data.json", DECK_FILE)

func copy_file(source: String, target: String):
	if FileAccess.file_exists(source):
		var file = FileAccess.open(source, FileAccess.ModeFlags.READ)
		var content = file.get_as_text()
		file.close()

		var target_file = FileAccess.open(target, FileAccess.ModeFlags.WRITE)
		if target_file:
			target_file.store_string(content)
			target_file.close()
			print("File copied from %s to %s" % [source, target])
		else:
			print("Failed to open target file for writing:", target)

# โหลดการ์ดและ Universal Core
func load_cards_and_cores():
	var cards_data = read_json_file(CARDS_FILE)
	var cores_data = read_json_file(CORES_FILE)
	all_cards = cards_data.get("cards", [])
	all_cores = cores_data.get("universal_cores", [])
	update_card_list()
	update_core_lists()

# โหลดข้อมูลเด็ค
func load_local_decks():
	var loaded_data = read_json_file(DECK_FILE)
	local_decks = loaded_data if loaded_data.size() > 0 else {
		"deck1": {"core": "", "special_cards": [], "cards": []},
		"deck2": {"core": "", "special_cards": [], "cards": []},
		"deck3": {"core": "", "special_cards": [], "cards": []}
	}
	save_local_decks()

func save_local_decks():
	write_json_file(DECK_FILE, local_decks)

# อ่าน JSON
func read_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("File not found:", file_path)
		return {}
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) == OK:
		return json.data
	else:
		print("Error parsing JSON: ", json.error_message)
		return {}

# เขียน JSON
func write_json_file(file_path: String, data: Dictionary):
	var json_string = JSON.stringify(data, "\t")
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Data successfully saved to: ", file_path)
	else:
		print("Failed to open file for writing: ", file_path)

# อัปเดต UI
func update_ui():
	update_card_list()
	update_core_lists()
	update_selected_deck_ui()

# อัปเดตรายการการ์ด (แถวละ 10 ใบใน ScrollContainer)
func update_card_list():
	var grid_container = $ManageDeckPanel/CardList/GridContainer

	# ลบการ์ดเดิมทั้งหมด
	for child in grid_container.get_children():
		child.queue_free()

	# เพิ่มการ์ดแต่ละใบใน GridContainer
	grid_container.columns = 10  # แถวละ 10 ใบ
	for card in all_cards:
		var button = Button.new()
		button.text = card["name"]
		button.connect("pressed", Callable(self, "_on_card_selected").bind(card["name"]))
		grid_container.add_child(button)

# อัปเดตรายชื่อ Universal Core
func update_core_lists():
	for i in range(3):
		var scroll_container = $DeckPanel.get_node("Deck%dContainer/UniversalList%d" % [i + 1, i + 1])
		var hbox_container = scroll_container.get_node("HBoxContainer")

		# ล้างข้อมูลเก่าใน HBoxContainer
		for child in hbox_container.get_children():
			child.queue_free()

		# เพิ่มปุ่มใหม่สำหรับแต่ละ core
		for core in all_cores:
			var button = Button.new()
			button.text = core["name"]
			button.connect("pressed", Callable(self, "_on_core_selected").bind(core["name"]))
			hbox_container.add_child(button)

# ฟังก์ชันเมื่อเลือก Core
func _on_core_selected(core_name: String):
	print("Selected core:", core_name)

# อัปเดตเด็คที่เลือก
func update_selected_deck_ui():
	# ตรวจสอบว่ามี selected_scroll อยู่
	var selected_scroll = $ManageDeckPanel/SelectedCardsScroll/GridContainer

	# ล้างข้อมูลเก่าใน GridContainer
	for child in selected_scroll.get_children():
		child.queue_free()

	selected_scroll.columns = 10  # ตั้งค่าจำนวนคอลัมน์เป็น 10

	# ตรวจสอบว่ามี selected_deck ใน local_decks
	if not local_decks.has(selected_deck):
		print("Error: Selected deck '%s' not found in local_decks!" % selected_deck)
		return

	var deck_data = local_decks[selected_deck]
	var card_counts = {}

	# นับจำนวนการ์ดแต่ละใบใน selected_deck
	for card in deck_data["cards"]:
		card_counts[card] = card_counts.get(card, 0) + 1

	# เพิ่มการ์ดใน GridContainer
	for card_name in card_counts.keys():
		var count = card_counts[card_name]

		# ค้นหาระดับของการ์ด
		var index = all_cards.find({"name": card_name})
		var card_level = "unknown"  # ค่าเริ่มต้น
		if index != null:
			card_level = all_cards[index]["level"]

		# สร้างปุ่มสำหรับการ์ด
		var button = Button.new()
		button.text = "%s x%d (%s)" % [card_name, count, card_level]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.connect("pressed", Callable(self, "_on_selected_card_pressed").bind(card_name))

		selected_scroll.add_child(button)



# ฟังก์ชันเมื่อเลือกเด็ค
func select_deck(deck_key: String):
	selected_deck = deck_key
	update_selected_deck_ui()
	print("Selected deck:", selected_deck)
