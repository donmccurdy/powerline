class ListCollection extends EventEmitter

	constructor: (user, twitter) ->
		@$el = $('.collection-wrap')
		@$collection = null
		@user = user
		@twitter = twitter
		@toolbar = null
		@selection = null
		@lists = []
		@available_lists = []
		@init()

	init: () ->
		# Lists
		has_lists = $.Deferred()
		@twitter.getLists().done (lists) =>
			@available_lists = lists
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

	render: () ->
		# collection ui
		@$el.html JST.collection(@)
		@$collection = @$el.find('.collection')
		@toolbar = new Toolbar(@$el.find('.toolbar'), @)

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
			self.onUserClick userID, listID

	onUserClick: (userID, listID) ->
		list = @getList listID
		if @selection?.list.id is listID
			@selection.toggleUser userID
		else
			@selection?.destroy()
			@selection = new Selection(list)
			list.setSelection @selection
			@selection.toggleUser userID

	getList: (listID) ->
		_(@lists).where(id: +listID).first()

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

	pluck: (property) ->
		_.pluck @lists, property
