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
		@el = $('.collection-wrap')
		@footer = $('.footer')
		@collection = null
		@user = user
		@twitter = twitter
		@cache = new Cache(@user.id)
		@toolbar = null
		@selection = null
		@lists = []
		@openLists = []
		@commandQueue = new CommandQueue(@)
		@init()

	init: () ->
		# Lists
		list_metadata = []
		has_lists = $.Deferred()
		@twitter.getLists().done (data) =>
			for metadata in data.lists
				@addList metadata
			has_lists.resolve()
		
		# Following
		has_friends = $.Deferred()
		metadata =
			name: 'Following'
			member_count: @user.friends_count
		stream = new UserStream(0, metadata, @twitter)
		stream.ready().done =>
			list = new List(stream)
			list.setCollection @
			@lists.unshift list
			@openLists.unshift list
			has_friends.resolve()

		# Render
		$.when(has_lists, has_friends).done =>
			@lists = _.sortBy @lists, (l) -> l.name.toUpperCase()
			openListIDs = @cache.get('open-lists') or []
			@render()
			@openList(id) for id in openListIDs

	# Render
	#######################################

	render: () ->
		# collection ui
		@el.html JST.collection(@)
		@collection = @el.find('.collection')
		@toolbar = new Toolbar(@el.find('.toolbar'), @footer, @)

		# lists
		elements = _.map @openLists, (list) -> list.render()
		@collection.append elements

		@bindEvents()

	bindEvents: () ->
		self = @

		@collection.on 'click', '.user', (e) ->
			$this = $(this)
			userID = + $this.data 'id'
			listID = + $this.closest('.list').data 'id'
			self.select userID, listID, !(e.ctrlKey or e.metaKey), e.shiftKey

		@el.on 'click', '.toolbar-remove', => @removeFromList()

		@collection.sortable
			vertical: false
			handle: '.handle'
			itemSelector: 'section[sortable]'
			placeholder: '<section class="list-wrap placeholder"/>'
			onDrop: ($item, container, _super) =>
				_super($item, container)
				@updateListOrder()

	# Getters / Setters
	#######################################

	getList: (listID) ->
		_(@lists).where(id: +listID).first()

	addList: (metadata) ->
		stream = new UserStream(metadata.id, metadata, @twitter)
		stream.ready().done =>
			list = new List(stream)
			@lists.push list
			list.on 'destroy', => @removeList list.id
			list.on 'hide', => @closeList list.id

	removeList: (listID) ->
		list = @getList listID
		if list
			@closeList listID
			_.remove @lists, list
		@

	openList: (listID) ->
		unless _.findWhere(@openLists, id: listID)
			list = @getList listID
			@openLists.push list
			@cacheState()
			@collection.append list.render()
		@

	closeList: (listID) ->
		list = @getList listID
		if list and _.findWhere(@openLists, id: listID)
			_.remove @openLists, list
			@cacheState()
		@

	getUser: (userID) ->
		@twitter.getUser userID

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
			@trigger 'change'

	addToList: (listID) ->
		if @selection
			cmd = new AddCommand(@selection, @getList(listID))
			@commandQueue.push cmd
			@trigger 'change'

	removeFromList: () ->
		if @selection
			cmd = new RemoveCommand(@selection)
			@commandQueue.push cmd
			@selection.destroy()
			@trigger 'change'

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
		if @isModified()
			@commandQueue.save()


	isModified: () ->
		@commandQueue.isModified()

	# List Management
	#######################################

	update: (listChanges) ->
		list = @getList listChanges.id
		if list
			list.update listChanges
		else
			@addList listChanges
				.done => @openList listChanges.id
		@

	updateListOrder: () ->
		ids = []
		@collection.children().each ->
			ids.push $(this).find('.list').data('id')
		@openLists.length = 0
		@openLists = _.map ids, (id) => @getList id
		@cacheState()
		@

	getMembershipMap: () ->
		map = {}
		for list in @lists
			if list.id is 0 then continue
			for user in list.getUsers()
				map[user.id] = true
		map

	cacheState: () ->
		@cache.set 'open-lists', _.pluck(@openLists, 'id')

	# Debugging
	#######################################

	debug: () ->
		for list in @openLists
			unless list.id then continue
			console.group list.name
			list.debug()
			console.groupEnd()
