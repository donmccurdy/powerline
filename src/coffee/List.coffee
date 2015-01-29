class List extends EventEmitter

	constructor: (@stream) ->
		@id = +@stream.id
		@name = @stream.name
		@el = $(JST.list(@))
		@selection = null
		@isMutable = !!@id

		@users = @stream.current()
		@usersAdded = []
		@usersRemoved = []

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
		users = @usersAdded.concat(@users)
		if _.size @usersRemoved
			skip = _ @usersRemoved
				.pluck 'id'
				.invert()
				.value()
			users = _.filter users, (u) -> !skip[u.id]
		users

	getUsersInRange: (id1, id2) ->
		users = []
		inRange = false
		for user in @getUsers()
			if user.id is id1 or user.id is id2
				if inRange
					users.push user
					break
				inRange = true
			if inRange
				users.push user
		users

	add: (user) ->
		if @isMutable and not @contains user
			unless _.any(@users, id: user.id)
				@usersAdded.unshift user
			else
				_.remove @usersRemoved, id: user.id
		@render()
		@

	remove: (user) ->
		if @isMutable and @contains user
			if _.any(@users, id: user.id)
				@usersRemoved.push user
			else 
				_.remove @usersAdded, id: user.id
		@render()
		@

	contains: (user) ->
		_.any(@users, id: user.id) or _.any(@usersAdded, id: user.id)
