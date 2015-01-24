class List extends EventEmitter

	constructor: (@stream) ->
		@id = +@stream.id
		@name = @stream.name
		@el = $(JST.list(@))
		@selection = null
		@is_mutable = !!@id

		@users = @stream.current()
		@users_added = []
		@users_removed = []

	render: () ->
		rows = _.map @getUsers(), (user) =>
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

	getUsers: () ->
		users = @users_added.concat(@users)
		if _.size @users_removed
			ids = _ users
				.pluck 'id'
				.without _.pluck(@users_removed, 'id')
				.invert()
				.value()
			users = _ pool
				.filter (user) -> !!ids[user.id]
				.value()
		users

	add: (user) ->
		if @is_mutable and not @contains user
			@users_added.unshift user
			_.remove @users_removed, id: user.id
			console.log "User #{user.name} added to #{@name}"
		@render()
		@

	remove: (user) ->
		if @is_mutable and @contains user
			_.remove @users, id: user.id
			_.remove @users_added, id: user.id
			console.log "User '#{user.name}' removed from #{@name}"
		@render()
		@

	contains: (user) ->
		if _.first(@users, id: user.id)
			true
		if _.first(@users_added, id: user.id)
			true
		false
