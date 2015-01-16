class ListCollection extends EventEmitter

	constructor: (user, twitter) ->
		@el = $('.collection-wrap')
		@user = user
		@twitter = twitter
		@lists = []
		@available_lists = []
		@init()

	init: () ->
		has_lists = $.Deferred()
		has_friends = $.Deferred()
		@twitter.getLists().done (lists) =>
			@available_lists = lists
			has_lists.resolve()
		following = new List(0, @twitter)
		following.on 'load', =>
			@lists.push following
			has_friends.resolve()
		following.init()
		$.when(has_lists, has_friends).done => @render()

	render: () ->
		@el.html JST.collection(@)
		rows = _.map @lists, (list) -> list.render()
		@el.append rows

	bindEvents: () ->
		console.log 'bind events on ListCollection'

	pluck: (property) ->
		_.pluck @lists, property
