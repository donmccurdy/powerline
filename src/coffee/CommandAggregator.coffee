class CommandAggregator extends EventEmitter

	SAVE_INTERVAL: 90 # seconds
	SAVE_PADDING: 5 # lists

	constructor: (@collection) ->
		delay = (t, cbk) -> setTimeout cbk, t
		delay SAVE_INTERVAL, => @batch()

	batch: () ->
		if stillWaitingOnBatch? then return

		list = _ @collection.lists
			.filter (l) -> l.isModified()
			.sortBy (l) -> l.lastModified
			.first()

		unless list then return

		commands = @getCommandsByListID(list.id)
		@execute(commands)

	execute: (commands) ->
		doThing() # todo
			.done ->
				# remove from queue
				# list.setModified(false) / list.save()
				console.log 'success'
			.fail ->
				# leave in queue
				console.log 'eeeeek'
		@

	getCommandsByListID: (listID) ->
		[] # todo

