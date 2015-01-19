class Toolbar extends EventEmitter

	constructor: (@el, @collection) ->
		@bindEvents()

	setLists: (lists) ->
		@lists = lists

	bindEvents: () ->
		# list autosuggest
		$asg = @el.find('.input-list-search').asg
			delay: 20
			minChars: 0
			offsetTop: 16
			source: _.map @collection.available_lists, (list) ->
				{key: list.id, value: list.name}
			callback: =>
				@collection.push asg.get().key
				asg.clear()
		asg = $asg.data('asg')
