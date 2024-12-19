extends Node2D

const COLLISION_MASK_CARD = 1  # Mask สำหรับการ์ด
const COLLISION_MASK_SLOT = 2  # Mask สำหรับช่องสนาม

var selected_card = null  # เก็บการ์ดที่ถูกเลือก

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var clicked_card = raycast_check(COLLISION_MASK_CARD)
			var clicked_slot = raycast_check(COLLISION_MASK_SLOT)
			
			if clicked_card and clicked_card.get_parent().name == "hand":
				select_card(clicked_card)  # เลือกการ์ดจากมือ
			elif clicked_slot and selected_card:
				place_card_on_slot(selected_card, clicked_slot)  # วางการ์ดบนสนาม
				
# ตรวจจับสิ่งที่ถูกคลิก
func raycast_check(mask):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = mask
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# ฟังก์ชันเลือกการ์ด
func select_card(card):
	if selected_card:
		reset_card(selected_card)  # รีเซ็ตการ์ดที่ถูกเลือกก่อนหน้า
	selected_card = card
	card.scale = Vector2(1.2, 1.2)  # ขยายการ์ด
	card.z_index = 10
	print("Selected card:", card.name)

# ฟังก์ชันวางการ์ดในช่องสนาม
func place_card_on_slot(card, slot):
	card.global_position = slot.global_position  # ย้ายการ์ดไปยังตำแหน่งของช่อง
	card.reparent(slot.get_parent())  # ย้ายการ์ดออกจากมือไปยังสนาม
	reset_card(card)  # รีเซ็ตสถานะการ์ด
	selected_card = null
	print("Card placed on slot:", slot.name)

# ฟังก์ชันรีเซ็ตขนาดและสถานะการ์ด
func reset_card(card):
	card.scale = Vector2(1, 1)
	card.z_index = 1
