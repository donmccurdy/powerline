class List extends EventEmitter

	constructor: (@stream) ->
		@id = +@stream.id
		@name = @stream.name
		@el = $(JST.list(@))
		@users = @stream.current()
		@selection = null
		@is_mutable = !!@id

	render: () ->
		rows = _.map @users, (user) =>
			JST.user(user: user, selected: @selection?.contains user.id)
		@el.find('.list').html rows.join('')
		@bindEvents()
		@el

	setSelection: (selection) ->
		@selection = selection
		@selection.on 'destroy', => @selection = null
		@

	bindEvents: () ->
		console.log "bind events on List #{@id}"

	count: () ->
		@stream.count()

	add: (user) ->
		if @is_mutable
			@users.unshift user
			console.log "User #{user.name} added to #{@name}"
		@render()
		@

	remove: (user) ->
		if @is_mutable
			_.remove @users, id: user.id
			console.log "User '#{user.name}' removed from #{@name}"
		@render()
		@
