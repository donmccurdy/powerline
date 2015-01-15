class ListCollection extends EventEmitter

	constructor: ($el, twitterService) ->
		@el = $el
		@lists = []
		@twitter = twitterService
		@render()
		@bindEvents()

	render: () ->
		list.render() for list in @lists

	bindEvents: () ->
		console.log 'bind events'

	pluck: (property) ->
		_.pluck @lists, property
