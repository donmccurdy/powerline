class CommandAggregator extends EventEmitter

	constructor: (@twitter, @queue) ->
		@additions = {}
		@removals = {}
		@pending = []
		@init()

	init: () ->
		# Aggregate commands
		for cmd in @queue
			if cmd.is_adder
				@add cmd.destListID, cmd.userIDs
			if cmd.is_remover
				@remove cmd.srcListID, cmd.userIDs

		# Show modal
		@el = $ JST['modal'](content: JST['save-progress'](
			progress: 0
			error: false
		))
		@el.modal
			backdrop: true
			keyboard: true
			show: true

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
		@pending = add_results.concat add_results, del_results
		render = _.debounce (() => @render()), 100
		result.always(render) for result in @pending
		$.when.apply $, @pending

	render: () ->
		status = _.groupBy @pending, (cmd) -> cmd.state()
		@el.find('.modal-content').html(JST['save-progress'](
			progress: 100 * _.size(status.resolved) / _.size @pending
			error: !!_.size status.rejected
		))
		@
