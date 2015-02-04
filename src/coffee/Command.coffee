#
# Abstract Command
#
class Command extends EventEmitter
	constructor: (selection) ->
		@id = _.uniqueId()
		@userIDs = selection.get()
		@executed = false

	execute: (collection) ->
		@executed = true
		@

	undo: (collection) ->
		@executed = false
		@

	add: (collection, list) ->
		for userID in @userIDs.reverse()
			user = collection.getUser userID
			list.add user

	remove: (collection, list) ->
		for userID in @userIDs
			user = collection.getUser userID
			list.remove user

#
# Add user(s) to a list.
#
class AddCommand extends Command
	is_adder: true

	constructor: (selection, dest) ->
		super(selection)
		@destListID = dest.id

	execute: (collection) ->
		@add collection, collection.getList @destListID
		super()

	undo: (collection) ->
		@remove collection, collection.getList @destListID
		super()

#
# Remove user(s) from a list.
#
class RemoveCommand extends Command
	is_remover: true

	constructor: (selection) ->
		super(selection)
		@srcListID = selection.list.id

	execute: (collection) ->
		@remove collection, collection.getList @srcListID
		super()

	undo: (collection) ->
		@add collection, collection.getList @srcListID
		super()

#
# Move user(s) from one list to another.
#
class MoveCommand extends Command
	is_remover: true
	is_adder: true

	constructor: (selection, dest) ->
		super(selection)
		@srcListID = selection.list.id
		@destListID = dest.id

	execute: (collection) ->
		@add collection, collection.getList @destListID
		@remove collection, collection.getList @srcListID
		super()

	undo: (collection) ->
		@remove collection, collection.getList @destListID
		@add collection, collection.getList @srcListID
		super()
