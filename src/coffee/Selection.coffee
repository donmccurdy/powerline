class Selection extends EventEmitter

	constructor: (@list) ->
		@listID = @list.id
		@userIDs = []
		@anchorID = -1
		@cursorID = -1
		@list.setSelection @
		@on 'change', => @render()

	set: (userID, reset = false) ->
		if @contains userID
			if reset and @userIDs.length > 1
				@userIDs = [userID]
			else
				@userIDs = _.without @userIDs, userID
		else
			if reset
				@userIDs = [userID]
			else
				@userIDs.push userID
		if @contains userID
			@anchorID = @cursorID = userID
		@trigger 'change'

	setRange: (userID) ->
		if @anchorID > 0
			@userIDs = @getRange @anchorID, userID
			@cursorID = userID
			@trigger 'change'

	incr: (direction) ->
		users = @list.getUsers()
		index = direction + _.findIndex users, id: @anchorID
		@anchorID = @cursorID = users[index]?.id
		@userIDs = [@anchorID]
		@trigger 'change'

	incrRange: (direction) ->
		users = @list.getUsers()
		index = direction + _.findIndex users, id: @cursorID
		@cursorID = users[index]?.id
		@userIDs = @getRange @anchorID, @cursorID
		@trigger 'change'

	getRange: (id1, id2) ->
		users = []
		inRange = false
		for user in @list.getUsers()
			if user.id is id1 or user.id is id2
				if inRange or id1 is id2
					users.push user
					break
				inRange = true
			if inRange
				users.push user
		_.pluck users, 'id'

	count: () ->
		_.size @userIDs

	contains: (userID) ->
		_.contains @userIDs, userID

	get: () ->
		hash = _.invert @userIDs
		size = _.size @userIDs
		ids = []
		for user in @list.getUsers()
			if hash[user.id]
				ids.push user.id
			if size is ids.length
				break
		ids

	render: () ->
		@list.el.find('.selected').removeClass 'selected'
		for id in @userIDs
			@list.el.find(".user[data-id=#{id}]").addClass 'selected'

	destroy: () ->
		@list.el.find('.selected').removeClass 'selected'
		@trigger 'destroy'
