# Bootstrap
# 
# Kicks off main processes, and renders a static
# 	view for logged-out users.
#
class Bootstrap

	MAX_USERS: 2000

	twitter: null
	user: null

	constructor: () ->
		@$header = $('.pline-header')
		@friends = null
		@collection = null

	login: () ->
		@twitter = new TwitterService()
		if @twitter.isReady()
			@twitter.getCurrentUser().done (user) => @init user
		@render()

	init: (user) ->
		@user = user
		@collection = new ListCollection(@user, @twitter)
		@render()

	logout: () ->
		@twitter.logout()
		@user = null
		@collection = null
		@friends = null
		window.location.reload(false)

	start: () ->
		@$header
			.on 'click', '.btn-login', =>  
				@twitter.connectTwitter().then => @login()
			.on 'click', '.btn-logout', => @logout()

		window.onbeforeunload = => @onBeforeUnload()

		@login() # Log in automatically, if possible

	onBeforeUnload: () ->
		if @collection?.isModified()
			'Unsaved changes will be lost. Are you sure you want to continue?'

	render: () ->
		$('.navbar-right').html JST['navbar-right'](user: @user)
		$('.footer').html JST['footer'](user: @user)
		if @user.friends_count > @MAX_USERS and not @popup
			@popup = $ JST['modal'](content: JST['over-limits']())
			@popup.modal
				backdrop: true
				keyboard: true
				show: true
