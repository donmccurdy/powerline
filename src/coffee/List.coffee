class List extends EventEmitter

	constructor: ($el, twitterService) ->
		@el = $el
		@users = []
		@twitter = twitterService
		@render()
		@bindEvents()

	render: () ->
		user.render() for user in @users

	bindEvents: () ->
		console.log 'bind events'

	pluck: (property) ->
		_.pluck @users, property
