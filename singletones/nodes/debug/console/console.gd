extends Window

var commands: Dictionary

@onready var input: LineEdit = $"UI/CmdInput"
@onready var output: RichTextLabel = $"UI/OutputContainer/Output"

var history: Array = ['']
var position_in_history: int

func _ready():
	load_commands("res://engine/singletones/nodes/debug/console/commands/")
	
	self.print("[wave amp=50 freq=2][b][rainbow freq=0.2][center][font_size=24]Welcome to the Console![/font_size][/center][/rainbow][/b][/wave]")
	
	$"UI/Enter".pressed.connect(execute)
	close_requested.connect(
		func():
			get_tree().paused = false
			hide()
	)

func load_commands(dir: String) -> void:
	for cmd in DirAccess.get_files_at(dir):
		var command: Command = load(dir+cmd).register()
		commands[command.name] = command

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("a_console"):
		visible = !visible
		get_tree().paused = visible
	if visible:
		
		if Input.is_key_pressed(KEY_ESCAPE):
			grab_focus()
		
		if Input.is_action_just_pressed("ui_up"):
			move_history(1)
		if Input.is_action_just_pressed("ui_down"):
			move_history(-1)

func execute() -> void:	
	self.print("[b]> %s[/b]" % input.text)
	
	history.remove_at(0)
	history.push_front(input.text)
	history.push_front("")
	
	var args = input.text.split(' ')
	
	var cmdName = args[0]
	args.remove_at(0)
	
	input.clear()
	input.grab_focus()
	
	if !commands.has(cmdName):
		if cmdName != "":
			col_print("Command does not exist!", Color.RED)
		return
	
	self.print(commands[cmdName].try_execute(args))

func move_history(amount: int) -> void:
	position_in_history += amount
	position_in_history = clamp(position_in_history, 0, history.size() - 1)
	input.text = history[position_in_history]
	input.caret_column = input.text.length()

func print(msg: Variant) -> void:
	output.text += "%s\n" % msg
	print(msg)

func col_print(msg: String, col:Color) -> void:
	output.text += "[color=%s]%s[/color]\n" % [col.to_html(), msg]
	print(msg)

func _on_visibility_changed():
	input.grab_focus()
