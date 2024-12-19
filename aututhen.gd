extends Control

func _ready():
	
   
	# เชื่อมต่อ Callback ของ Firebase
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	if Firebase.Auth.check_auth_file():
		$VBoxContainer/StateLabel.text = 'Logged in'
		get_tree().change_scene_to_file('res://menu.tscn')
# ฟังก์ชันที่เรียกเมื่อกดปุ่ม Login
func _on_loginbutton_pressed():
	var email = $VBoxContainer/EmailLineEdit.text.strip_edges()
	var password = $VBoxContainer/PassWordLineEdit.text.strip_edges()

	# ตรวจสอบว่ามีการกรอกข้อมูล
	if email == "" or password == "":
		$VBoxContainer/StateLabel.text = "Please enter both email and password."
		return

	Firebase.Auth.login_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Logging in..."

# ฟังก์ชันที่เรียกเมื่อกดปุ่ม Signup
func _on_signinbutton_pressed():
	var email = $VBoxContainer/EmailLineEdit.text.strip_edges()
	var password = $VBoxContainer/PassWordLineEdit.text.strip_edges()

	# ตรวจสอบว่ามีการกรอกข้อมูล
	if email == "" or password == "":
		$VBoxContainer/StateLabel.text = "Please enter both email and password."
		return

	Firebase.Auth.signup_with_email_and_password(email, password)
	$VBoxContainer/StateLabel.text = "Signing up..."

# Callback เมื่อ Login สำเร็จ
func on_login_succeeded(auth):
	$VBoxContainer/StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file('res://menu.tscn')
# Callback เมื่อ Login ล้มเหลว
func on_login_failed(error_code, message):
	$VBoxContainer/StateLabel.text = "Login failed: %s" % message

# Callback เมื่อ Signup สำเร็จ
func on_signup_succeeded(auth):
	$VBoxContainer/StateLabel.text = "Signup success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file('res://menu.tscn')
# Callback เมื่อ Signup ล้มเหลว
func on_signup_failed(error_code, message):
	$VBoxContainer/StateLabel.text = "Signup failed: %s" % message
