# List
# 
# Represents a single list of Twitter users.
# 
# Delegates to:
# 	- Stream: Hides some of the details of
# 		pagination, and the differences between
# 		'real' lists and the Following pseudo-list.
#
class List extends EventEmitter

	constructor: (@stream) ->
		@id = +@stream.id
		@name = @stream.name
		@mode = @stream.mode
		@description = @stream.description
		@users = @stream.current()
		@pivot = 'all'
		@usersAdded = []
		@usersRemoved = []
		@selection = null
		@isMutable = !!@id
		@el = $(JST.list(@))
		@stream.on 'load', =>
			@users = @stream.current()
			@render()

	render: () ->
		rows = _.map @getUsers(), (user) =>
			JST.user(user: user, selected: @selection?.contains user.id)
		@el.html $(JST.list(@)).children()
			.find('.list').html rows.join('')
		@bindEvents()
		@el

	setSelection: (selection) ->
		@selection = selection
		@selection.on 'destroy', => @selection = null
		@

	bindEvents: () ->
		@el.on 'click', '.list-edit', =>
			form = new ListForm(@stream.twitter, @)
			form.on 'save', (metadata) => @update metadata
		@el.on 'click', '.list-hide', =>
			@trigger 'hide'
			@el.detach()
		@el.on 'click', '.list-remove', =>
			@stream.remove()
				.done => @destroy()
				.fail => console.log "could not delete list #{@id}"
		@el.on 'click', '.list-filter', (e) =>
			@filter $(e.target).data('pivot')
		@

	count: () ->
		@stream.count() + @usersAdded.length - @usersRemoved.length

	getUsers: () ->
		users = @usersAdded.concat(@users)
		if _.size @usersRemoved
			skip = _ @usersRemoved
				.pluck 'id'
				.invert()
				.value()
			users = _.filter users, (u) -> !skip[u.id]
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

	reload: () ->
		deferred = $.Deferred().done =>
			@users = @stream.current()
			@usersAdded = []
			@usersRemoved = []
			@render()
		@stream.reload(deferred)
		deferred

	filter: (pivot) ->
		@pivot = pivot
		# todo
		@render()

	update: (metadata) ->
		@name = metadata.name
		@mode = metadata.mode
		@description = metadata.description
		@render()
		@

	destroy: () ->
		@el.remove()
		@trigger 'destroy'

	debug: () ->
		console.group 'Users'
		console.log _.pluck(@users, 'name')
		console.groupEnd()
		console.group 'Added'
		console.log _.pluck(@usersAdded, 'name')
		console.groupEnd()
		console.group 'Removed'
		console.log _.pluck(@usersRemoved, 'name')
		console.groupEnd()

	contains: (user) ->
		_.any(@users, id: user.id) or _.any(@usersAdded, id: user.id)
