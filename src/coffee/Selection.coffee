class Selection extends EventEmitter

	constructor: (@list) ->
		@userIDs = []

	toggleUser: (userID, reset = false) ->
		if _.contains @userIDs, userID
			if reset
				@userIDs = []
			else
				_.remove @userIDs, userID
		else
			if reset
				@userIDs = [userID]
			else
				@userIDs.push userID
		@trigger 'change'
		@render()

	contains: (userID) ->
		_.contains @userIDs, userID

	getUsers: () ->
		hash = _.invert @userIDs
		size = _.size @userIDs
		ids = []
		for user in @list.users
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
