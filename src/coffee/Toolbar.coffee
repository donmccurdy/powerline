class Toolbar extends EventEmitter

	constructor: (@el, @collection) ->
		@bindEvents()

	setLists: (lists) ->
		@lists = lists

	bindEvents: () ->
		asg_options = 
			delay: 20
			minChars: 0
			numToSuggest: 100
			source: _.map @collection.available_lists, (list) ->
				{key: list.id, value: list.name}

		delay = (t, f) -> _.delay f, t

		# list search
		$asgSearch = @el.find('.input-list-search').asg(_.merge(asg_options,
			offsetTop: 14
			callback: =>
				@collection.push asgSearch.get().key
				asgSearch.clear()
		))
		asgSearch = $asgSearch.data('asg')

		# add user to list
		$asgAdd = @el.find('.dropdown-input-add').asg(_.merge(asg_options,
			staticPos: true
			namespace: 'asg-static'
			container: @el.find('.dropdown-input-add + .asg-ul')
			callback: =>
				@collection.addToList asgAdd.get().key
				asgAdd.clear()
				$asgAdd.blur()
		))
		asgAdd = $asgAdd.data('asg')

		# move user to list
		# TODO

		# when an certain buttons are clicked, focus an input
		@el.on 'click', '.btn-input-start', ->
			$menu = $(this).next('.dropdown-menu').addClass 'focus'
			$menu.find '.dropdown-input'
				.focus()
				.one 'blur', -> delay(200, -> $menu.removeClass 'focus' )
