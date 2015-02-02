class UserStream

	@STREAM_ERROR = 'could not connect stream'

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
			.fail => deferred?.reject @STREAM_ERROR

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
