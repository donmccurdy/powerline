class List extends EventEmitter

	constructor: (id, twitter) ->
		@twitter = twitter
		@id = id

	init: () ->
		if @id is 0
			@twitter.getFriends().done (users) =>
				@users = users
				@name = 'Following'
				@trigger 'load'
		else
			throw "unknown list #{id}"

	render: () ->
		rows = _.map @users, (user) -> JST.user(user)
		@el = @el or $(".list[data-id=#{@id}]")
		@el.html rows.join('')
		@bindEvents()
		@el

	bindEvents: () ->
		console.log "bind events on List #{@id}"

	pluck: (property) ->
		_.pluck @users, property
