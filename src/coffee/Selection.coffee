class Selection extends EventEmitter

	constructor: (@list) ->
		@userIDs = []
		@on 'change', => @render()

	toggleUser: (userID, reset = false) ->
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
		@trigger 'change'

	addUser: (userID, reset = false) ->
		unless @contains userID
			if reset then @userIDs = [userID]
			else @userIDs.push userID
		@trigger 'change'
		@

	set: (userIDs) ->
		@userIDs = userIDs
		@trigger 'change'

	count: () ->
		_.size @userIDs

	contains: (userID) ->
		_.contains @userIDs, userID

	getUsers: () ->
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
