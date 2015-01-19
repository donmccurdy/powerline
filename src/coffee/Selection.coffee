class Selection extends EventEmitter

	constructor: (@listID) ->
		@userIDs = []

	toggleUser: (userID) ->
		if _.contains @userIDs, userID
			@userIDs = []
		else
			@userIDs = [userID]
		@trigger 'change'
		
	contains: (userID) ->
		_.contains @userIDs, userID

	getUsers: () ->
		@userIDs
