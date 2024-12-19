extends Node2D

var room_data: Dictionary = {}  # เก็บข้อมูลห้องทั้งหมด
var player_id = ""
var db_ref = Firebase.Database.get_database_reference("rooms")  # อ้างอิง Firebase Database ไปยัง "rooms"

@onready var room_list = $ScrollContainer/roomlist  # ItemList สำหรับแสดงรายการห้อง
@onready var room_name_input = $roomname  # LineEdit สำหรับป้อนชื่อห้อง
@onready var player_name_input = $playername  # LineEdit สำหรับป้อนชื่อผู้เล่น

func _ready():
	player_id = Firebase.Auth.auth.localid  # ดึง localid จาก Firebase Auth
	if player_id == "":
		print("ผู้ใช้ไม่ได้เข้าสู่ระบบ")
		return

	# เชื่อมต่อ signals สำหรับการอัปเดตข้อมูล Firebase
	db_ref.new_data_update.connect(new_data_updated)
	db_ref.patch_data_update.connect(patch_data_updated)
	print("ระบบพร้อมใช้งาน")

# อัปเดตรายการห้องใน ItemList
func update_room_list():
	room_list.clear()  # ล้างรายการเก่า
	for room_name in room_data.keys():
		room_list.add_item(room_name)  # เพิ่มชื่อห้องใน ItemList

# ฟังก์ชันจัดการข้อมูลใหม่ที่เพิ่มใน Firebase
func new_data_updated(data):
	print("เพิ่มห้องใหม่:", data)
	if data.key.is_empty():
		room_data = data.data
	else:
		room_data[data.key] = data.data

	update_room_list()

# ฟังก์ชันจัดการข้อมูลที่เปลี่ยนแปลงใน Firebase
func patch_data_updated(data):
	print("ข้อมูลเปลี่ยนแปลง:", data)
	if data.key.is_empty():
		room_data = data.data
	else:
		room_data[data.key] = data.data

	update_room_list()

# ฟังก์ชันสร้างห้องใหม่
func _on_createroom_pressed():
	var room_name = room_name_input.text.strip_edges()
	if room_name == "":
		print("ชื่อห้องต้องไม่ว่างเปล่า!")
		return

	if room_data.has(room_name):
		print("ชื่อห้องซ้ำ! กรุณาเลือกชื่ออื่น")
		return

	var player_name = player_name_input.text.strip_edges()
	if player_name == "":
		print("กรุณาป้อนชื่อผู้เล่น!")
		return

	# เพิ่มห้องใน Firebase
	var new_room = {
		"players": {
			player_id: {
				"name": player_name,
				"status": "ไม่พร้อม"
			}
		}
	}
	# ใช้ path เป็น room_name โดยตรง
	var path = room_name
	db_ref.update(path, new_room)
	print("สร้างห้องสำเร็จ:", room_name)

	# เปลี่ยนไปหน้า waitingroom.tscn
	get_tree().change_scene_to_file("res://waitingroom.tscn")

# ฟังก์ชันเข้าร่วมห้อง
func _on_joinroom_pressed():
	var room_name = room_name_input.text.strip_edges()
	if room_name == "":
		print("กรุณาป้อนชื่อห้องก่อนเข้าร่วม!")
		return

	if not room_data.has(room_name):
		print("ไม่พบห้อง:", room_name)
		return

	var player_name = player_name_input.text.strip_edges()
	if player_name == "":
		print("กรุณาป้อนชื่อผู้เล่น!")
		return

	var player_data = {
		"name": player_name,
		"status": "ไม่พร้อม"
	}
	# ใช้ path เป็น room_name โดยตรง
	var path = room_name + "/players/" + player_id
	db_ref.update(path, player_data)
	print("เข้าร่วมห้องสำเร็จ:", room_name)

	# เปลี่ยนไปหน้า waitingroom.tscn
	get_tree().change_scene_to_file("res://waitingroom.tscn")

# ฟังก์ชันค้นหาห้อง
func _on_searchroom_pressed():
	var room_name = room_name_input.text.strip_edges()
	if room_name == "":
		print("กรุณาป้อนชื่อห้องเพื่อค้นหา!")
		return

	room_list.clear()  # ล้างรายการเก่า
	if room_data.has(room_name):
		room_list.add_item(room_name)
		print("พบห้อง:", room_name)
	else:
		print("ไม่พบห้อง:", room_name)

# ฟังก์ชันออกจากระบบ
func _on_backtomenubutton_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	print("กลับไปยังเมนูหลัก")
