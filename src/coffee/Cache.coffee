# Cache Service
#
# Basic implementation of an in-memory + LocalStorage cache.
#
class Cache

	@instance: null

	@create: (userID) ->
		unless @instance
			@instance = new Cache(userID)
		@instance

	constructor: (@userID) ->
		@cache = JSON.parse(localStorage.getItem @getBin())
		date = new Date().toLocaleDateString()
		unless @cache?.date is date
			@cache = {}
			@cache.date = date

	get: (key) ->
		@cache[key]

	set: (key, value) ->
		@cache[key] = value
		@persist()
		@

	persist: () ->
		localStorage.setItem @getBin(), JSON.stringify @cache
		@

	clear: (key) ->
		delete @cache[key]
		@persist()
		@

	getBin: (key) ->
		"tmp-cache-#{@userID}"

	bind: (key, fetch) ->		
		if data = @get(key)
			Promise.resolve data
		else
			fetch().then (data) => @set(key, data)
