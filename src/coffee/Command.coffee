#
# Abstract Command
#
class Command extends EventEmitter
	constructor: (selection) ->
		@id = _.uniqueId()
		@userIDs = selection.getUsers()
		@executed = false

	execute: (collection) ->
		@executed = true
		@

	undo: (collection) ->
		@executed = false
		@

	add: (collection, list) ->
		for userID in @userIDs
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
	constructor: (selection) ->
		super(selection)
		@listID = selection.list.id

	execute: (collection) ->
		@remove collection, collection.getList @listID
		super()

	undo: (collection) ->
		@add collection, collection.getList @listID
		super()

#
# Move user(s) from one list to another.
#
class MoveCommand extends Command
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
