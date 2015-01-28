#
# CommandQueue
# 
# Implements (or at least leaves room for
# 	eventual implementation of) undo/redo
# 	functionality.
#
class CommandQueue
	constructor: (@collection) ->
		@finalized = []
		@undoQueue = []
		@redoQueue = []

	push: (cmd) ->
		cmd.execute @collection
		@undoQueue.push cmd
		@redoQueue.length = 0

	pop: (cmd) ->
		cmd = @undoQueue.pop()
		cmd.undo @collection
		@redoQueue.push cmd

	save: () ->
		changes = new CommandAggregator(@collection.twitter, @undoQueue)
		changes.apply()
			.done =>
				@finalized = @undoQueue
				@undoQueue = []
				@redoQueue = []
			.fail ->
				console.log "Could not save changes"
				console.log arguments
