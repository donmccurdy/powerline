class ListCollection extends EventEmitter

	constructor: (user, twitter) ->
		@$el = $('.collection-wrap')
		@$select = null
		@user = user
		@twitter = twitter
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
		stream = new UserStream(0, 'Following', @twitter)
		stream.ready().done =>
			@lists.push(new List(stream))
			has_friends.resolve()

		# Render
		$.when(has_lists, has_friends).done => @render()

	render: () ->
		# collection ui
		@$el.html JST.collection(@)
		@$collection = @$el.find('.collection')
		@$select = @$el.find('.available-lists')

		# lists
		elements = _.map @lists, (list) -> list.render()
		@$collection.append elements

		@bindEvents()

	bindEvents: () ->
		@$select.on 'change', =>
			@push(@$select.val())

	push: (id) ->
		name = _(@available_lists)
			.where(id: +id)
			.pluck('name')
			.first()
		stream = new UserStream(id, name, @twitter)
		stream.ready().done =>
			list = new List(stream)
			@$collection.append list.render()
			@lists.push list

	pluck: (property) ->
		_.pluck @lists, property
