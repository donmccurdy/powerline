class UserStream

	@STREAM_ERROR = 'could not connect stream'

	constructor: (@id, @metadata, @twitter) ->
		@localCursor = -1
		@remoteCursor = -1
		@users = []
		@name = @metadata.name
		@is_ready = $.Deferred()
		@reload @is_ready, false


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
		@is_ready

	current: () ->
		@users

	next: () ->
		if @localCursor >= 0
			throw "can't access page #{@localCursor}"
		else
			@is_ready

	count: () ->
		@metadata.member_count
