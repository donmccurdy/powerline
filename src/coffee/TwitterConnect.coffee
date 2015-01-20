# Twitter Service
#
# Handles authorization (through OAuth.io), fetching
# 	details for the current user, and fetching a list
# 	of friends.
#
# We'll need to support more complicated Twitter API
# 	interactions, so most of that will probably
# 	need to be located elsewhere.
#
class TwitterConnect

	cache: new Cache()
	users: {}
	authResult: false
	listeners:
		ready: []

	publish: (event, data) ->
		@listeners[event].forEach (cbk) -> cbk(data)

	initialize: ->
		OAuth.initialize 'K7fLOqzxZpGs6BJeSikeQFoSlbc', cache:true
		@authResult = OAuth.create 'twitter'
		if @authResult
			@publish 'ready'

	isReady: ->
		@authResult

	on: (event, callback) ->
		@listeners[event].push(callback)

	connectTwitter: ->
		deferred = $.Deferred()
		OAuth.popup 'twitter', cache: true, (error, result) =>
			if error then return
			@authResult = result
			deferred.resolve()
			@publish 'ready'
		deferred

	logout: ->
		OAuth.clearCache 'twitter'
		@authResult = false

	getCurrentUser: ->
		$d = @cache.bind 'current-user', (deferred) =>
			@authResult?.get('/1.1/account/verify_credentials.json').done (data) =>
				deferred.resolve data
		$d.done (data) => @cacheUsers [data]
		$d

	getUser: (userID) ->
		if @users[userID]
			@users[userID]
		else
			throw 'remote user fetching not implemented'

	cacheUsers: (users) ->
		_.defer =>
			for user in users
				@users[user.id] = user unless @users[user.id]
					


	getFriends: (cursor) ->
		options = 
			cursor: cursor
			count: 200 # max = 200, 15 / 15 min
			skip_status: true
			include_user_entities: false
		$d = @cache.bind "friends-#{cursor}", (deferred) =>
			@authResult.get('/1.1/friends/list.json?' + $.param(options)).done (data) =>
				deferred.resolve data
		$d.done (data) => @cacheUsers data.users
		$d

	getLists: (cursor) ->
		return @cache.bind "lists", (deferred) =>
			@authResult.get('/1.1/lists/list.json?' + $.param(reverse: true)).done (data) ->
				deferred.resolve data

	getListMembers: (listID, cursor) ->
		options =
			list_id: listID
			cursor: cursor
			count: 200 # max = 5000, 180 / 15 min
			skip_status: true
			include_entities: false
		$d = @cache.bind "list-#{listID}-#{cursor}", (deferred) =>
			@authResult.get("/1.1/lists/members.json?" + $.param(options)).done (data) =>
				deferred.resolve data
		$d.done (data) => @cacheUsers data.users
		$d
