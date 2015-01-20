#
# CommandQueue
# 
# Implements (or at least leaves room for
# 	eventual implementation of) undo/redo
# 	functionality.
#
class CommandQueue
	constructor: (@collection) ->
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
