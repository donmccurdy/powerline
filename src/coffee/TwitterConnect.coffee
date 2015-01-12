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
	authResult: false
	listeners:
		ready: []

	publish: (event, data) ->
		@listeners[event].forEach((cbk) -> cbk(data))

	initialize: ->
		OAuth.initialize 'K7fLOqzxZpGs6BJeSikeQFoSlbc', cache:true
		@authResult = OAuth.create 'twitter'
		if @authResult
			publish 'ready'

	isReady: ->
		@authResult

	on: (event, callback) ->
		@listeners[event].push(callback)

	connectTwitter: ->
		deferred = $.Deferred();
		OAuth.popup 'twitter', cache: true, (error, result) ->
			if (error)
				return
			@authResult = result
			deferred.resolve()
			publish 'ready'
		deferred

	clearCache: ->
		OAuth.clearCache 'twitter'
		@authResult = false

	getCurrentUser: ->
		return @cache.bind 'current-user', (deferred) ->
			@authResult.get('/1.1/account/verify_credentials.json').done (data) ->
				deferred.resolve(data)

	getFriends: ->
		return @cache.bind 'all-friends', (deferred) ->
			@authResult.get('/1.1/friends/list.json').done (data) ->
				deferred.resolve(data)
