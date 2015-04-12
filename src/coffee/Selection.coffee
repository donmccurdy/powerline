class Selection extends EventEmitter

	constructor: (@list) ->
		@listID = @list.id
		@userIDs = []
		@anchorID = -1
		@cursorID = -1
		@list.setSelection @
		@on 'change', => @render()

	# Select/deselect given user.
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

	# Select all from anchor to given user.
	setRange: (userID) ->
		if @anchorID > 0
			@userIDs = @getRange @anchorID, userID
			@cursorID = userID
			@trigger 'change'

	# Move cursor to next user.
	incr: (direction = 1) ->
		users = @list.getUsers()
		index = direction + _.findIndex users, id: @cursorID
		@anchorID = @cursorID = users[index]?.id
		@userIDs = [@anchorID]
		@trigger 'change'

	# Extend selection to next cursor position.
	incrRange: (direction = 1) ->
		users = @list.getUsers()
		index = direction + _.findIndex users, id: @cursorID
		if users[index]
			@cursorID = users[index].id
			@userIDs = @getRange @anchorID, @cursorID
			@trigger 'change'

	decr: () ->
		@incr -1

	decrRange: () ->
		@incrRange -1

	# Get User IDs.
	# 
	# Outside code shouldn't see @userIDs because
	# 	it's (1) unsorted, and (2) not checked
	# 	for uniqueness.
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

	# Get IDs between a given pair.
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

	# Return index of anchor user. Useful
	# 	when moving cursor left/right 
	# 	between lists.
	getAnchorIndex: () ->
		_.findIndex @list.getUsers(), id: @anchorID

	# Select the user at the specified index,
	# 	and remove all other selections.
	setAnchorIndex: (index) ->
		users = @list.getUsers()
		if index < users.length then @set users[index].id
		else @set _.last(users).id

	count: () ->
		_.size @userIDs

	contains: (userID) ->
		_.contains @userIDs, userID

	render: () ->
		@list.el.find('.selected').removeClass 'selected'
		for id in @userIDs
			@list.el.find(".user[data-id=#{id}]").addClass 'selected'

	destroy: () ->
		@list.el.find('.selected').removeClass 'selected'
		@trigger 'destroy'
