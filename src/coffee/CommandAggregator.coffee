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

	getListIDs: () ->
		_.union _.keys(@additions), _.keys(@removals)

	apply: (commands) ->
		add_results = _.map @additions, (userIDs, listID) => @twitter.addListMembers(listID, userIDs)
		del_results = _.map @removals, (userIDs, listID) => @twitter.removeListMembers(listID, userIDs)
		results = add_results.concat add_results, del_results
		$.when.apply $, results
