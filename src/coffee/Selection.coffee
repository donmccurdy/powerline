class Selection extends EventEmitter

	constructor: (@list) ->
		@userIDs = []

	toggleUser: (userID) ->
		if _.contains @userIDs, userID
			@userIDs = []
		else
			@userIDs = [userID]
		@trigger 'change'
		@render()
		
	contains: (userID) ->
		_.contains @userIDs, userID

	getUsers: () ->
		@userIDs

	render: () ->
		@list.el.find('.selected').removeClass 'selected'
		for id in @userIDs
			@list.el.find(".user[data-id=#{id}]").addClass 'selected'

	destroy: () ->
		@list.el.find('.selected').removeClass 'selected'
		@trigger 'destroy'
