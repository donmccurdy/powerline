class Bootstrap
	constructor: () ->
		console.log 'Je suis'

	config: () ->
		console.log 'config()'

bootstrap = new Bootstrap()
bootstrap.config()

# Exports
window.Bootstrap = Bootstrap
window.TwitterConnect = TwitterConnect
window.Cache = Cache