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
class TwitterService extends EventEmitter

	cache: null
	users: {}

	# Login / Initialization
	#######################################

	constructor: (clientID, oauthProxy) ->
		hello.init {twitter: clientID}, {oauth_proxy: oauthProxy}
		@twitter = hello 'twitter'
		if @isReady() then @init()

	init: ->
		uid = @twitter.getAuthResponse().user_id
		@cache = Cache.create uid
		@trigger 'ready'

	isReady: ->
		!!@twitter.getAuthResponse()

	connectTwitter: ->
		@twitter.login().then =>
				@init()
				# resolved here ... (?)
				@trigger 'ready'

	logout: ->
		@twitter.logout()
		@twitter = false

	# AJAX Requests
	#######################################

	request: (path, data, method) ->
		params = ''
		if data
			# doing this for *both* GET+POST requests because
			#	POST bodies aren't going through as expected.
			params = '?' + $.param data
		if method is 'get'
			data = {}
		promise = new Promise((resolve, reject) ->
			@twitter.api path + params, method, data
			.then (data) ->
				if data?.errors
					reject data
				else
					resolve data
			.catch (data) -> 
				reject data
		)
		promise

	get: (path, data) ->
		@request path, data, 'get'

	post: (path, data) ->
		@request path, data, 'post'

	# API Definition
	#######################################

	getCurrentUser: ->
		@cache.bind 'current-user', () =>
				@get 'me'
			.then (data) => @cacheUsers [data]

	getUser: (userID) ->
		if @users[userID]
			@users[userID]
		else
			throw 'remote user fetching not implemented'

	cacheUsers: (users) ->
		_.defer =>
			for user in users
				unless @users[user.id]
					user.muting = user.muting or false
					user.thumbnail = user.profile_image_url_https or user.profile_image_url
					@users[user.id] = user

	getFriends: (cursor) ->
		@cache.bind "friends-#{cursor}", () =>
				@get '/friends/list.json',
					count: 200 # max = 200, 15 / 15 min
					cursor: cursor
					skip_status: true
					include_user_entities: false
			.then (data) => @cacheUsers data.users

	getLists: (clear = false) ->
		if clear then @cache.clear 'lists'
		return @cache.bind 'lists', () =>
			@get '/lists/ownerships.json', count: 100

	getListMembers: (listID, cursor, clear = false) ->
		if clear then @cache.clear "list-#{listID}-#{cursor}"
		@cache.bind "list-#{listID}-#{cursor}", () =>
				@get '/lists/members.json',
					count: 200 # max = 5000, 180 / 15 min
					list_id: listID
					cursor: cursor
					skip_status: true
					include_entities: false
			.then (data) => @cacheUsers data.users

	addListMembers: (listID, userIDs) ->
		@post '/lists/members/create_all.json',
				list_id: listID
				user_id: userIDs.join(',')

	removeListMembers: (listID, userIDs) ->
		@post '/lists/members/destroy_all.json',
				list_id: listID
				user_id: userIDs.join(',')

	upsertList: (metadata) ->
		@cache.clear 'lists'
		if metadata.id
			@post '/lists/update.json',
				list_id: metadata.id
				name: metadata.name
				mode: metadata.mode
				description: metadata.description
		else
			@post '/lists/create.json',
				name: metadata.name
				mode: metadata.mode
				description: metadata.description

	removeList: (listID) ->
		@cache.clear 'lists'
		@post '/lists/destroy.json', list_id: listID
