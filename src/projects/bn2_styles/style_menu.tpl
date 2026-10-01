@archive style_menu
@size 9

script 0 mmbn2 {
	end
}
script 1 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	"Use which style?\n"
	option
		left = 1
		right = 1
		up = 0
		down = 0
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 1
		down = 1
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 2 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	"Use which style?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	"More"
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 3 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	"Use which style?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 2
		down = 2
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 2
		right = 2
		up = 0
		down = 0
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 4 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	"Use which style?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 3
		down = 3
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 0
	space
		count = 2
	"More"
	spaceLeft
		count = 11
	option
		left = 2
		right = 2
		up = 1
		down = 1
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 5 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	"Use which style?\n"
	option
		left = 1
		right = 1
		up = 2
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 3
		down = 3
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 0
	space
		count = 2
	printItem
		buffer = 3
		item = 0
	spaceLeft
		count = 11
	option
		left = 2
		right = 2
		up = 1
		down = 1
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 6 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	option
		left = 1
		right = 1
		up = 4
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 4
		down = 3
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 4
	space
		count = 2
	printItem
		buffer = 3
		item = 0
	spaceLeft
		count = 11
	option
		left = 2
		right = 2
		up = 1
		down = 4
	space
		count = 2
	"More"
	"\n"
	option
		left = 4
		right = 4
		up = 2
		down = 0
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 7 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	option
		left = 1
		right = 1
		up = 4
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 4
		down = 3
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 4
	space
		count = 2
	printItem
		buffer = 3
		item = 0
	spaceLeft
		count = 11
	option
		left = 2
		right = 2
		up = 1
		down = 4
	space
		count = 2
	printItem
		buffer = 4
		item = 0
	"\n"
	option
		left = 4
		right = 4
		up = 2
		down = 0
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
script 8 mmbn2 {
	msgOpenQuick
	mugshotShow
		mugshot = MegaMan
	textSpeed
		delay = 0
	option
		left = 1
		right = 1
		up = 4
		down = 2
	space
		count = 2
	printItem
		buffer = 1
		item = 0
	spaceLeft
		count = 11
	option
		left = 0
		right = 0
		up = 5
		down = 3
	space
		count = 2
	printItem
		buffer = 2
		item = 0
	"\n"
	option
		left = 3
		right = 3
		up = 0
		down = 4
	space
		count = 2
	printItem
		buffer = 3
		item = 0
	spaceLeft
		count = 11
	option
		left = 2
		right = 2
		up = 1
		down = 5
	space
		count = 2
	printItem
		buffer = 4
		item = 0
	"\n"
	option
		left = 5
		right = 5
		up = 2
		down = 0
	space
		count = 2
	"More"
	spaceLeft
		count = 11
	option
		left = 4
		right = 4
		up = 3
		down = 1
	space
		count = 2
	"Cancel"
	select
		default = 0
		disableB = false
		clear = false
		targets = [
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue,
			jump = continue
		]
	waitHold
}
