class Keymap

	##############################
	# NAVIGATION
	
	@UP_ARROW:
		action: 'Select Above'
		label: '↑'
		key: ['up', 'shift+up']

	@DOWN_ARROW:
		action: 'Select Below'
		label: '↓'
		key: ['down', 'shift+down']

	@LEFT_ARROW:
		action: 'Select Left'
		label: '←'
		key: ['left', 'shift+left']

	@RIGHT_ARROW:
		action: 'Select Right'
		label: '→'
		key: ['right', 'shift+right']

	##############################
	# LISTS
	
	@LIST_ADD:
		action: 'Add to list'
		label: 'L'
		key: 'l'

	@LIST_MOVE:
		action: 'Move to list'
		label: 'Shift + L'
		key: 'shift+l'

	@LIST_REMOVE:
		action: 'Remove from list'
		label: 'E'
		key: 'e'

	##############################
	# UTILITY

	@SEARCH:
		action: 'Search'
		label: '/'
		key: '/'

	@SELECT_ALL:
		action: 'Select All'
		label: 'Control/Command + A'
		key: ['ctrl+a', 'meta+a']

	@SHOW_ACTIONS:
		action: 'More Actions'
		label: '.'
		key: '.'

	@SHOW_DETAILS:
		action: 'Show Details'
		label: 'Spacebar'
		key: 'space'

	@UNDO:
		action: 'Undo'
		label: 'Control/Command + Z'
		key: ['ctrl+z', 'meta+z']

	@REDO:
		action: 'Redo'
		label: 'Control/Command + Shift + Z'
		key: ['ctrl+shift+z', 'cmd+shift+z']
