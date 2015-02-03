class Toolbar extends EventEmitter

	constructor: (@el, @footer, @collection) ->
		@bindEvents()
		@bindKeys()

	setLists: (lists) ->
		@lists = lists

	focusDropdown: (action) ->
		$menu = @el.find(".dropdown-menu[data-action=#{action}]")
			.addClass 'focus'
		$menu.find '.dropdown-input'
			.focus()
			.one 'blur', -> _.delay (-> $menu.removeClass 'focus'), 200

	bindEvents: () ->
		self = @
		asg_options = 
			delay: 20
			minChars: 0
			numToSuggest: 100
			source: _.map @collection.availableLists, (list) ->
				{key: list.id, value: list.name}

		# list search
		$asgSearch = @el.find('.input-list-search').asg(_.merge(asg_options,
			offsetTop: 14
			callback: =>
				@collection.addList asgSearch.get().key
				asgSearch.clear()
				$asgSearch.blur()
		))
		asgSearch = $asgSearch.data('asg')

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

	bindKeys: () ->
		Mousetrap.bind Keymap.LIST_ADD.key, (e) =>
			@focusDropdown 'add'
			e.preventDefault()
		Mousetrap.bind Keymap.LIST_MOVE.key, (e) =>
			@focusDropdown 'move'
			e.preventDefault()
		Mousetrap.bind Keymap.LIST_REMOVE.key, (e) =>
			@collection.removeFromList()
			e.preventDefault()

		$('body').on 'keydown', (e) =>
			unless @collection.selection?.count() then return

			captured = true
			switch e.which
				when Keymap.UP_ARROW.keyCode
					@collection.extendSelection -1, not e.shiftKey
				when Keymap.DOWN_ARROW.keyCode
					@collection.extendSelection +1, not e.shiftKey
				when Keymap.LEFT_ARROW.keyCode
					console.log Keymap.LEFT_ARROW.name
				when Keymap.RIGHT_ARROW.keyCode
					console.log Keymap.RIGHT_ARROW.name
				else
					captured = false
			if captured then e.preventDefault()
