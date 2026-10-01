@archive elem_choice
@size 20

script 0 mmbn2 {
	end
}
script 1 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 0
		right = 0
		up = 0
		down = 0
	space
		count = 2
	"Elec"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = continue
		]
	end
}
script 2 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 0
		right = 0
		up = 0
		down = 0
	space
		count = 2
	"Heat"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 17,
			jump = continue
		]
	end
}
script 3 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Heat"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 17,
			jump = continue
		]
	end
}
script 4 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 0
		right = 0
		up = 0
		down = 0
	space
		count = 2
	"Aqua"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 18,
			jump = continue
		]
	end
}
script 5 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Aqua"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 18,
			jump = continue
		]
	end
}
script 6 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Heat"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Aqua"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 17,
			jump = 18,
			jump = continue
		]
	end
}
script 7 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	"Heat"
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Aqua"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 17,
			jump = 18,
			jump = continue
		]
	end
}
script 8 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 0
		right = 0
		up = 0
		down = 0
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 19,
			jump = continue
		]
	end
}
script 9 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 19,
			jump = continue
		]
	end
}
script 10 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Heat"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 17,
			jump = 19,
			jump = continue
		]
	end
}
script 11 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	"Heat"
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 17,
			jump = 19,
			jump = continue
		]
	end
}
script 12 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	"Aqua"
	"   "
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 18,
			jump = 19,
			jump = continue
		]
	end
}
script 13 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	"Aqua"
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 18,
			jump = 19,
			jump = continue
		]
	end
}
script 14 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	"Heat"
	"   "
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	"Aqua"
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 17,
			jump = 18,
			jump = 19,
			jump = continue
		]
	end
}
script 15 mmbn2 {
	mugshotShow
		mugshot = MegaMan
	msgOpen
	"""
	Lan! My data is
	changing...! Pick an
	element for me!
	"""
	keyWait
	clearMsg
	"Which element?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	"Elec"
	"   "
	option
		left = 0
		right = 0
		up = 3
		down = 3
	space
		count = 2
	"Heat"
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 0
	space
		count = 2
	"Aqua"
	"   "
	option
		left = 2
		right = 2
		up = 1
		down = 1
	space
		count = 2
	"Wood"
	select
		default = 0
		disableB = true
		clear = true
		targets = [
			jump = 16,
			jump = 17,
			jump = 18,
			jump = 19,
			jump = continue
		]
	end
}
script 16 mmbn2 {
	flagClear
		flag = 57
	flagClear
		flag = 58
	end
}
script 17 mmbn2 {
	flagSet
		flag = 57
	flagClear
		flag = 58
	end
}
script 18 mmbn2 {
	flagClear
		flag = 57
	flagSet
		flag = 58
	end
}
script 19 mmbn2 {
	flagSet
		flag = 57
	flagSet
		flag = 58
	end
}
