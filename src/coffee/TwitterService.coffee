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
class TwitterService

	cache: new Cache()
	users: {}
	authResult: false
	listeners:
		ready: []

	publish: (event, data) ->
		@listeners[event].forEach (cbk) -> cbk(data)

	initialize: ->
		hello.init twitter: 'EZIGSwadFs8Z23g35SXUYDri1'
		@twitter = hello 'twitter'
		if @twitter.getAuthResponse()
			@publish 'ready'

	isReady: ->
		!!@twitter.getAuthResponse()

	on: (event, callback) ->
		@listeners[event].push(callback)

	connectTwitter: ->
		deferred = $.Deferred()
		@twitter.login().then(
			(r) =>
				deferred.resolve()
				@publish 'ready'
			(r) =>
				deferred.reject r
		)
		deferred

	logout: ->
		@twitter.logout()
		@twitter = false

	getCurrentUser: ->
		$d = @cache.bind 'current-user', (deferred) =>
			@twitter.api 'me'
				.then(
					(data) -> deferred.resolve data
					(data) -> deferred.reject data
				)

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
				unless @users[user.id]
					user.thumbnail = user.profile_image_url_https or user.profile_image_url
					@users[user.id] = user

	getFriends: (cursor) ->
		$d = @cache.bind "friends-#{cursor}", (deferred) =>
			@twitter.api '/friends/list.json', 'get',
					count: 200 # max = 200, 15 / 15 min
					cursor: cursor
					skip_status: true
					include_user_entities: false
				.then(
					(data) -> deferred.resolve data
					(data) -> deferred.reject data
				)
		$d.done (data) => @cacheUsers data.users
		$d

	getLists: (clear = false) ->
		if clear then @cache.clear 'lists'
		return @cache.bind 'lists', (deferred) =>
			@twitter.api '/lists/ownerships.json', 'get', count: 100
				.then(
					(data) -> deferred.resolve data.lists
					(data) -> deferred.reject data
				)

	getListMembers: (listID, cursor, clear = false) ->
		if clear then @cache.clear "list-#{listID}-#{cursor}"
		$d = @cache.bind "list-#{listID}-#{cursor}", (deferred) =>
			@twitter.api '/lists/members.json', 'get',
					count: 200 # max = 5000, 180 / 15 min
					list_id: listID
					cursor: cursor
					skip_status: true
					include_entities: false
				.then(
					(data) -> deferred.resolve data
					(data) -> deferred.reject data
				)
		$d.done (data) => @cacheUsers data.users
		$d

	addListMembers: (listID, userIDs) ->
		@twitter.api '/lists/members/create_all.json', 'post',
				list_id: listID
				user_id: userIDs.join(',')
			.then(
				(data) -> console.log data
				(data) -> console.error data
			)

	removeListMembers: (listID, userIDs) ->
		deferred = $.Deferred()
		@twitter.api '/lists/members/destroy_all.json', 'post',
				list_id: listID
				user_id: userIDs.join(',')
			.then(
				(data) -> deferred.resolve data
				(data) -> deferred.reject data
			)
		deferred

	upsertList: (metadata) ->
		@cache.clear 'lists'
		deferred = $.Deferred()
		if metadata.id
			req = @twitter.api '/lists/update.json', 'post',
				list_id: metadata.id
				name: metadata.name
				mode: metadata.mode
				description: metadata.description
		else
			req = @twitter.api '/lists/create.json', 'post',
				name: metadata.name
				mode: metadata.mode
				description: metadata.description
		req.then(
			(data) -> deferred.resolve data
			(data) -> deferred.reject data
		)
		deferred


	removeList: (listID) ->
		@cache.clear 'lists'
		deferred = $.Deferred()
		@twitter.api '/lists/destroy.json', 'post', list_id: listID
			.then(
				(data) -> deferred.resolve data
				(data) -> deferred.reject data
			)
		deferred
