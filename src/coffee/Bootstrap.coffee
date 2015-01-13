class Bootstrap

	twitter: null,
	user: null,

	constructor: () ->
		@twitter = new TwitterConnect();
		@$header = $('.pline-header');

	login: () ->
		if @twitter.isReady()
			@twitter.getCurrentUser().then (user) =>
				@user = user
		@render()

	logout: () ->
		@twitter.clearCache()
		@user = null
		window.location.reload(false)

	start: () ->
		@twitter.initialize()

		@$header
			.on 'click', '.btn-login', =>  
				@twitter.connectTwitter().then => @login()
			.on 'click', '.btn-logout', => @logout()

		@login() # Log in automatically, if possible

	render: () ->
		$('.navbar-right').html(JST['navbar-right'](user: @user))
