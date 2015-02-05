class Bootstrap

	twitter: null,
	user: null,

	constructor: () ->
		@twitter = new TwitterService()
		@$header = $('.pline-header')
		@friends = null
		@collection = null

	login: () ->
		if @twitter.isReady()
			@twitter.getCurrentUser().done (user) =>
				@user = user
				@collection = new ListCollection(@user, @twitter)
				@render()
		@render()

	logout: () ->
		@twitter.logout()
		@user = null
		@collection = null
		@friends = null
		window.location.reload(false)

	start: () ->
		@twitter.initialize()

		@$header
			.on 'click', '.btn-login', =>  
				@twitter.connectTwitter().then => @login()
			.on 'click', '.btn-logout', => @logout()

		@login() # Log in automatically, if possible

	render: () ->
		$('.navbar-right').html JST['navbar-right'](user: @user)
		$('.footer').html JST['footer'](user: @user)
