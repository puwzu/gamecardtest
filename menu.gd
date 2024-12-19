extends Control

# ตัวแปรเก็บชื่อผู้เล่น
var player_name = ""

# ไฟล์ที่ใช้เก็บข้อมูล
const SAVE_FILE = "user://player_data.json"

func _ready() -> void:
	# ซ่อน Popup ตั้งแต่เริ่มต้น
	if $Options:
		$Options.hide()
	if $HowToPlay:
		$HowToPlay.hide()

	# โหลดค่าชื่อผู้เล่นจากไฟล์
	load_player_name()

	# เชื่อม Signal ของ LineEdit


func _on_playername_text_submitted(new_text: String) -> void:
	player_name = new_text  # อัปเดตค่าชื่อผู้เล่น
	save_player_name()  # บันทึกค่าลงไฟล์
	print("Player Name Saved: ", player_name)

func save_player_name():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var data = {"player_name": player_name}  # สร้างข้อมูลในรูปแบบ Dictionary
		file.store_string(JSON.stringify(data))  # ใช้ JSON.stringify() แทน JSON.print()
		file.close()
		print("Player Name successfully saved to file.")
	else:
		print("Failed to open file for saving!")

func load_player_name():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_parser = JSON.new()  # สร้างอินสแตนซ์ JSON
			var parse_result = json_parser.parse(file.get_as_text())  # ใช้ parse กับ json_parser
			if parse_result == OK:  # ตรวจสอบสถานะว่า parse สำเร็จ
				var data = json_parser.get_data()  # ดึงข้อมูล JSON ที่ parse สำเร็จ
				if "player_name" in data:
					player_name = data["player_name"]  # โหลดค่าจากไฟล์
					$playername.text = player_name  # ตั้งค่าลงใน LineEdit
					print("Player Name Loaded: ", player_name)
			else:
				print("Failed to parse JSON data. Error code: ", parse_result)
			file.close()
		else:
			print("Failed to open file for loading!")
	else:
		print("Save file does not exist.")














# ฟังก์ชันเปลี่ยน Scene ไปยัง Lobby
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://lobby.tscn")

# ฟังก์ชันเปลี่ยน Scene ไปยัง Deck Room
func _on_deck_button_pressed() -> void:
	get_tree().change_scene_to_file("res://deckroom1.tscn")

# ฟังก์ชันปรับระดับเสียง
func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

# ฟังก์ชันเปลี่ยนภาษา
func _on_change_language_button_pressed() -> void:
	print("Change Language Button Pressed")
	# เพิ่มระบบเปลี่ยนภาษาที่นี่

# แสดง Popup วิธีการเล่น
func _on_how_to_play_button_pressed() -> void:
	if $PopupPanel_HowToPlay:
		$PopupPanel_HowToPlay.show()

# ปิด Popup วิธีการเล่น
func _on_how_to_play_close_pressed() -> void:
	if $PopupPanel_HowToPlay:
		$PopupPanel_HowToPlay.hide()

# Logout Button
func _on_logout_button_pressed() -> void:
	if Firebase.Auth:
		Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://aututhen.tscn")

# Exit Button
func _on_exit_button_pressed() -> void:
	get_tree().quit()

# เปิด Popup Options
func _on_optionbutton_pressed() -> void:
	if $Options:
		$Options.show()
