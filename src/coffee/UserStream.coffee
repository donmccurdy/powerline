class UserStream

	@STREAM_ERROR = 'could not connect stream'

	constructor: (@id, @metadata, @twitter) ->
		@localCursor = -1
		@remoteCursor = -1
		@users = []
		@name = @metadata.name
		@is_ready = $.Deferred()

		if @id is 0
			resource = @twitter.getFriends(@remoteCursor)
		else
			resource = @twitter.getListMembers(@id, @remoteCursor)

		resource
			.done (data) =>
				@remoteCursor = data.next_cursor
				@users = data.users
				@is_ready.resolve(@users)
			.fail => throw @STREAM_ERROR

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
