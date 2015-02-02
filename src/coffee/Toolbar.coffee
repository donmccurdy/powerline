class Toolbar extends EventEmitter

	constructor: (@el, @footer, @collection) ->
		@bindEvents()

	setLists: (lists) ->
		@lists = lists

	bindEvents: () ->
		asg_options = 
			delay: 20
			minChars: 0
			numToSuggest: 100
			source: _.map @collection.availableLists, (list) ->
				{key: list.id, value: list.name}

		delay = (t, f) -> _.delay f, t

		# list search
		$asgSearch = @el.find('.input-list-search').asg(_.merge(asg_options,
			offsetTop: 14
			callback: =>
				@collection.push asgSearch.get().key
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
		@el.on 'click', '.btn-input-start', ->
			$menu = $(this).next('.dropdown-menu').addClass 'focus'
			$menu.find '.dropdown-input'
				.focus()
				.one 'blur', -> delay(200, -> $menu.removeClass 'focus' )

		# save button in footer
		@footer.on 'click', '.toolbar-save', => @collection.save()

		# when selection changes, update add/move/remove buttons
		@collection.on 'select',  =>
			$('.toolbar-add').prop 'disabled', !@collection.selection?.count()
			$('.toolbar-move, .toolbar-remove').prop 'disabled',
				!@collection.selection?.list.isMutable

		# create new list
		@el.on 'click', '.toolbar-create', =>
			listForm = new ListForm(@collection.twitter)
			listForm.on 'save', (list) => @collection.update list
