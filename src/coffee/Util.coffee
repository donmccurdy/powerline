RegExp.quote = (string) ->
	string.replace /[-\\^$*+?.()|[\]{}]/g, '\\$&'
