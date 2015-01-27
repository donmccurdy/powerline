class CommandAggregator extends EventEmitter

	constructor: (@twitter, @queue) ->
		@additions = {}
		@removals = {}
		@init()

	init: () ->
		for cmd in @queue
			if cmd.is_adder
				@add cmd.destListID, cmd.userIDs
			if cmd.is_remover
				@remove cmd.srcListID, cmd.userIDs

	add: (listID, userIDs) ->
		unless @additions[listID]
			@additions[listID] = []
		@additions[listID] = _.union(@additions[listID], userIDs)

	remove: (listID, userIDs) ->
		unless @removals[listID]
			@removals[listID] = []
		@removals[listID] = _.union(@removals[listID], userIDs)

	apply: (commands) ->
		for own listID, additions of @additions
			console.log "Adding " + additions.join(',') + " to #{listID}"
		for own listID, removals of @removals
			console.log "Removing " + removals.join(',') + " from #{listID}"
		$.Deferred().resolve()
