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
		@available_lists = []
		@commandQueue = new CommandQueue(@)
		@init()

	init: () ->
		# Lists
		has_lists = $.Deferred()
		@twitter.getLists().done (lists) =>
			@available_lists = _.sortBy lists, (l) ->
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

	getUser: (userID) ->
		@twitter.getUser userID

	push: (id) ->
		metadata = _(@available_lists)
			.where(id: +id)
			.first()
		unless metadata
			throw "No such list: #{id}"
		stream = new UserStream(id, metadata, @twitter)
		stream.ready().done =>
			list = new List(stream)
			@$collection.append list.render()
			@lists.push list

	# Selection Management
	#######################################

	select: (userID, listID, reset, range) ->
		list = @getList listID

		if range and listID is @lastSelectListID and @selection?.contains @lastSelectUserID
			# Range selection
			users = list.getUsersInRange @lastSelectUserID, userID
			@selection.set _.pluck(users, 'id')
		else
			# Individual selection
			if @selection?.list.id is listID
				@selection.toggleUser userID, reset
			else
				@selection?.destroy()
				@selection = new Selection(list)
				list.setSelection @selection
				@selection.toggleUser userID
			@lastSelectUserID = userID
			@lastSelectListID = listID
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

	# Save Changes
	#######################################

	save: () ->
		@commandQueue.save()
