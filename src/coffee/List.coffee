class List extends EventEmitter

	constructor: (@stream) ->
		@id = @stream.id
		@name = @stream.name
		@el = $(JST.list(@))
		@users = @stream.current()

	render: () ->
		rows = _.map @users, (user) -> JST.user(user)
		@el.find('ol').html rows.join('')
		@bindEvents()
		@el

	bindEvents: () ->
		console.log "bind events on List #{@id}"
