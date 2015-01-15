class Keymap

	##############################
	# NAVIGATION
	
	UP_ARROW:
		action: 'Select Above'
		key: '↑'
		keyCode: 38

	DOWN_ARROW:
		name: 'Select Below'
		key: '↓'
		keyCode: 40

	LEFT_ARROW:
		name: 'Select Left'
		key: '←'
		keyCode: 37

	RIGHT_ARROW:
		name: 'Select Right'
		key: '→'
		keyCode: 39

	##############################
	# LISTS
	
	LIST_ADD:
		name: 'Add to list'
		key: 'L'
		keyCode: 76

	LIST_MOVE:
		name: 'Move to list'
		key: 'SHIFT + L'
		keyCode: 76
		keyModifiers:
			shift: true

	LIST_REMOVE:
		name: 'Remove from list'
		key: 'E'
		keyCode: 69

	##############################
	# UTILITY

	SEARCH:
		name: 'Search'
		key: '/'
		keyCode: 191

	SELECT_ALL:
		name: 'Select All'
		key: 'CMD + A'
		keyCode: 65
		keyModifiers:
			meta: true

	SHOW_ACTIONS:
		name: 'More Actions'
		key: '.'
		keyCode: 190

	SHOW_DETAILS:
		name: 'Show Details'
		key: 'Spacebar'
		keyCode: 32

	UNDO:
		name: 'Undo'
		key: 'CTRL + Z'
		keyCode: 90
		keyModifiers:
			ctrl: true

	REDO:
		name: 'Redo'
		key: 'CTRL + SHIFT + Z'
		keyCode: 90
		keyModifiers:
			ctrl: true
			shift: true
