class List extends EventEmitter

	constructor: (@stream) ->
		@id = +@stream.id
		@name = @stream.name
		@el = $(JST.list(@))
		@users = @stream.current()
		@selection = null

	render: () ->
		rows = _.map @users, (user) =>
			JST.user(user: user, selected: @selection?.contains user.id)
		@el.find('.list').html rows.join('')
		@bindEvents()
		@el

	setSelection: (selection) ->
		@selection = selection
		@selection.on 'destroy', => @selection = null

	bindEvents: () ->
		console.log "bind events on List #{@id}"
