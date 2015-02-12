# Cache Service
#
# Basic implementation of an in-memory + LocalStorage cache.
#
class Cache

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
			deferred = $.Deferred().resolve data
		else
			fetch().done (data) =>
				@set(key, data)
