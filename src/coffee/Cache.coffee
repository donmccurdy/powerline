# Cache Service
#
# Basic implementation of an in-memory + LocalStorage cache.
#
# TODO This is a pretty naïve approach. A production-ready
#	implementation will probably need to involve expiration
#	times and better clear functions.
#
class Cache

	cache: {}

	get: (key) ->
		if @cache[key]
			return @cache[key]
		else if (json = localStorage.getItem(key))
			return JSON.parse json
		null

	set: (key, value) ->
		@cache[key] = value
		localStorage.setItem key, JSON.stringify(value)

	clear: (key) ->
		@cache[key] = null
		localStorage.removeItem key

	bind: (key, fetch) ->		
		if data = @get(key)
			deferred = $.Deferred().resolve data
		else
			fetch().done (data) =>
				@set(key, data)
