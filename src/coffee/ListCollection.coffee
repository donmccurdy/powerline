# List Collection
# 
# Represents the main workspace, comprised of
# 	one or more lists that can exchange users.
# 	
# 	Delegates to:
#
# 	- Toolbar: UI+hotkey bindings
# 	- Twitter: Interacts with Twitter API
# 	- Selection: Manages selection state
# 	- List: Represents a single list
# 	- CommandQueue: Tracks changes for save/undo/redo
#
class ListCollection extends EventEmitter

	constructor: (user, twitter) ->
		@$el = $('.collection-wrap')
		@$footer = $('.footer')
		@$collection = null
		@user = user
		@twitter = twitter
		@toolbar = null
		@selection = null
		@lists = []
		@availableLists = []
		@commandQueue = new CommandQueue(@)
		@init()

	init: () ->
		# Lists
		has_lists = $.Deferred()
		@twitter.getLists().done (data) =>
			@availableLists = _.sortBy data.lists, (l) ->
				l.name.toUpperCase()
			has_lists.resolve()
		
		# Following
		has_friends = $.Deferred()
		metadata =
			name: 'Following'
			member_count: @user.friends_count
		stream = new UserStream(0, metadata, @twitter)
		stream.ready().done =>
			@lists.push(new List(stream))
			has_friends.resolve()

		# Render
		$.when(has_lists, has_friends).done => @render()

	# Render
	#######################################

	render: () ->
		# collection ui
		@$el.html JST.collection(@)
		@$collection = @$el.find('.collection')
		@toolbar = new Toolbar(@$el.find('.toolbar'), @$footer, @)

		# lists
		elements = _.map @lists, (list) -> list.render()
		@$collection.append elements

		@bindEvents()

	bindEvents: () ->
		self = @
		@$collection.on 'click', '.user', (e) ->
			$this = $(this)
			userID = + $this.data 'id'
			listID = + $this.closest('.list').data 'id'
			self.select userID, listID, !(e.ctrlKey or e.metaKey), e.shiftKey
		@$el.on 'click', '.toolbar-remove', => @removeFromList()

	# Getters / Setters
	#######################################

	getList: (listID) ->
		_(@lists).where(id: +listID).first()

	addList: (listID) ->
		metadata = _(@availableLists)
			.where(id: +listID)
			.first()
		unless metadata
			throw "No such list: #{listID}"
		stream = new UserStream(listID, metadata, @twitter)
		stream.ready().done =>
			@push new List(stream)

	getUser: (userID) ->
		@twitter.getUser userID

	push: (list) ->
		@$collection.append list.render()
		@lists.push list
		list.on 'destroy', =>
			_.remove @lists, (l) -> l.id is list.id

	# Selection Management
	#######################################

	select: (userID, listID, reset, range) ->
		list = @getList listID

		if range and listID is @selection?.listID
			# Range selection
			@selection.setRange userID
		else
			# Individual selection
			if @selection?.list.id is listID
				@selection.set userID, reset
			else
				@selection?.destroy()
				@selection = new Selection(list)
				@selection.on 'change', => @trigger 'select'
				@selection.on 'destroy', =>
					@selection = null
					@trigger 'select'
				@selection.set userID
		@

	moveToList: (listID) ->
		if @selection
			cmd = new MoveCommand(@selection, @getList(listID))
			@commandQueue.push cmd
			@selection.destroy()

	addToList: (listID) ->
		if @selection
			cmd = new AddCommand(@selection, @getList(listID))
			@commandQueue.push cmd

	removeFromList: () ->
		if @selection
			cmd = new RemoveCommand(@selection)
			@commandQueue.push cmd
			@selection.destroy()

	showDetails: () ->
		if @selection.count() is 1
			user = @getUser @selection.get()[0]
			$(JST['modal'](content: JST['user-detail'](user))).modal
				backdrop: true
				keyboard: true
				show: true

	# Save Changes
	#######################################

	save: () ->
		@commandQueue.save()

	# List Management
	#######################################

	update: (listChanges) ->
		list = @getList listChanges.id
		if list
			list.update(listChanges)
		else
			@availableLists.push listChanges
			@availableLists = _.sortBy @availableLists, (l) ->
				l.name.toUpperCase()

	# Debugging
	#######################################

	debug: () ->
		for list in @lists
			unless list.id then continue
			console.group list.name
			list.debug()
			console.groupEnd()
