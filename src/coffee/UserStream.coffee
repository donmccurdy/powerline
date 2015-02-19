class UserStream extends EventEmitter

	constructor: (@id, @metadata, @twitter) ->
		@localCursor = -1
		@remoteCursor = -1
		@users = []
		@name = @metadata.name
		@mode = @metadata.mode
		@description = @metadata.description
		@isReady = $.Deferred()
		@reload @isReady, false


	reload: (deferred, noCache = true) ->
		@remoteCursor = -1
		if @id is 0
			resource = @twitter.getFriends @remoteCursor, noCache
		else
			resource = @twitter.getListMembers @id, @remoteCursor, noCache

		resource
			.done (data) =>
				@remoteCursor = data.next_cursor
				@users = data.users
				deferred?.resolve @users
				@preload noCache
			.fail => deferred?.reject 'could not connect stream'

	preload: (noCache) ->
		if not @remoteCursor
			return @
		else if @id is 0
			resource = @twitter.getFriends @remoteCursor, noCache
		else
			resource = @twitter.getListMembers @id, @remoteCursor, noCache

		resource
			.done (data) =>
				@remoteCursor = data.next_cursor
				@users = @users.concat data.users
				@preload noCache
				@trigger 'load'
		@

	ready: () ->
		@isReady

	current: () ->
		@users

	next: () ->
		if @localCursor >= 0
			throw "can't access page #{@localCursor}"
		else
			@isReady

	count: () ->
		@users.length

	remove: () ->
		@twitter.removeList @id