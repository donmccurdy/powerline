class Toolbar extends EventEmitter

	constructor: (@el, @footer, @collection) ->
		@bindEvents()
		@bindKeys()

	setLists: (lists) ->
		@lists = lists

	focusDropdown: (action) ->
		$btn = @el.find ".btn[data-action=#{action}]"
		unless $btn.prop 'disabled'
			$menu = @el.find ".dropdown-menu[data-action=#{action}]"
				.addClass 'focus'
			$menu.find '.dropdown-input'
				.focus()
				.one 'blur', -> $menu.removeClass 'focus'

	bindEvents: () ->
		self = @
		asg_options = 
			delay: 20
			minChars: 0
			numToSuggest: 100
			source: @findList
			clickEvent: 'mousedown'

		# list search
		$asgOpen = @el.find('.input-list-open').asg(_.merge(asg_options,
			offsetTop: 14
			callback: =>
				@collection.openList asgOpen.get().key
				asgOpen.clear()
				$asgOpen.blur()
		))
		asgOpen = $asgOpen.data('asg')
		@$asgOpen = $asgOpen

		# add user to list
		$asgAdd = @el.find('.dropdown-input[data-action=add]').asg(_.merge(asg_options,
			staticPos: true
			namespace: 'asg-static'
			container: @el.find('.dropdown-input-results[data-action=add]')
			callback: =>
				@collection.addToList asgAdd.get().key
				asgAdd.clear()
				$asgAdd.blur()
		))
		asgAdd = $asgAdd.data('asg')

		# move user to list
		$asgMove = @el.find('.dropdown-input[data-action=move]').asg(_.merge(asg_options,
			staticPos: true
			namespace: 'asg-static'
			container: @el.find('.dropdown-input-results[data-action=move]')
			callback: =>
				@collection.moveToList asgMove.get().key
				asgMove.clear()
				$asgMove.blur()
		))
		asgMove = $asgMove.data('asg')

		# when an certain buttons are clicked, focus an input
		@el.on 'click', '.btn-input-start', -> self.focusDropdown $(this).data 'action'

		# save button in footer
		@footer.on 'click', '.toolbar-save', => @collection.save()

		# when selection changes, update add/move/remove buttons
		@collection.on 'select',  =>
			$('.toolbar-add').prop 'disabled', !@collection.selection?.count()
			$('.toolbar-move, .toolbar-remove').prop 'disabled',
				!@collection.selection?.list.isMutable or !@collection.selection?.count()

		# create new list
		@el.on 'click', '.toolbar-create', =>
			listForm = new ListForm(@collection.twitter)
			listForm.on 'save', (list) => @collection.update list

		# bind tooltips
		@el.find('[data-toggle="tooltip"]').tooltip(delay: show: 1000, hide: 0)

	findList: (id, label, callback) =>
		lists = _.filter @collection.lists, (l) -> !!l.id
		if id
			lists = _.where lists, id: id
		else if label
			re1 = new RegExp('^' + RegExp.quote(label), 'i')
			re2 = new RegExp(RegExp.quote(label), 'i')
			primary = _.filter lists, (l) -> l.name.match re1
			secondary = _.filter lists, (l) -> l.name.match re2
			lists = _.unique primary.concat(secondary)
		callback(_.map lists, (l) -> key: l.id, value: l.name)

	bindKey: (key, callback) ->
		Mousetrap.bind key, (e) ->
			callback(e)
			e.preventDefault()

	bindKeys: () ->
		# list actions
		@bindKey Keymap.LIST_ADD.key, => @focusDropdown 'add'
		@bindKey Keymap.LIST_MOVE.key, => @focusDropdown 'move'
		@bindKey Keymap.LIST_REMOVE.key, => @collection.removeFromList()
		@bindKey Keymap.LIST_OPEN.key, => @$asgOpen.focus()

		# keyboard selection
		@bindKey Keymap.UP.key, (e) =>
			if e.shiftKey then @collection.selection?.decrRange()
			else @collection.selection?.decr()
		@bindKey Keymap.DOWN.key, (e) =>
			if e.shiftKey then @collection.selection?.incrRange()
			else @collection.selection?.incr()
		@bindKey Keymap.LEFT.key, (e) =>
			if e.shiftKey then @collection.moveLeft()
			else @collection.selectLeft()
		@bindKey Keymap.RIGHT.key, (e) =>
			if e.shiftKey then @collection.moveRight()
			else @collection.selectRight()

		# user details
		@bindKey Keymap.SHOW_DETAILS.key, (e) => @collection.showDetails()

		# blur inputs on escape
		$('input').keydown (e) -> $(this).blur() if e.keyCode is 27
